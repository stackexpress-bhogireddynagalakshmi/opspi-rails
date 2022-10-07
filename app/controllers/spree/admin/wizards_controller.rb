# frozen_string_literal: true

module Spree
  module Admin
    class WizardsController < Spree::Admin::BaseController
      include ApisHelper
      include ResetPasswordConcern
      include ResourceLimitHelper
      include ApplicationHelper
      
      before_action :ensure_user_confirmed,  except: [:show, :index, :new]
      before_action :set_batch_jobs, only: %i[index show]
      before_action :ensure_hosting_panel_access
      before_action -> { resource_limit_check(wizard_params[:server_type],'domain') }, except: [:show, :index, :new]

      def index; end
      def new; end

      def create
        @domain      = wizard_params[:domain]
        @server_type = wizard_params[:server_type]

        unless @limit_exceed[:success]
          @error = @limit_exceed[:message]
          render 'new'
          return
        end
        if valid_domain?(@domain)
          create_user_domain
          @tasks = []
          
          build_tasks
          
          TaskManager::TaskProcessor.new(current_spree_user, @tasks).call
          
          flash[:success] =  I18n.t("wizards.wizard_started")
          
          set_batch_jobs


          redirect_to admin_wizard_path(id: @batch_jobs.keys.last)
        else
          @error = @error ||= 'Invalid domain name'
          render 'new'
        end
      end

      def show
        @tasks = @batch_jobs[params[:id]] || @batch_jobs[params[:id].to_i]
        @user_domain = current_spree_user.user_domains.find_by_domain(@tasks.first["domain"])
      end

      
      private

      def build_tasks
        prepare_dns_task
          prepare_web_domain_task

        if wizard_params[:enable_ftp_service] == 'y'
          prepare_ftp_account_task
        end

        if wizard_params[:enable_db_service] == 'y' 
          prepare_database_task
        end

        # if wizard_params[:enable_mail_service] == 'y'
          prepare_mail_domain_task

          if wizard_params[:emails].present?
            prepare_mail_box_task
          end
        # end 

        @tasks = @tasks.flatten
      end

      def prepare_dns_task
        @tasks <<
          [
            {
              id: 1,
              type: "create_dns_domain",
              domain: @domain,
              user_domain_id: @user_domain.id,
              data:
                  {
                    name: @domain,
                    mbox: "admin@#{get_sanitized_domain(@domain)}",
                    refresh: '7200',
                    retry: '540',
                    expire: '604800',
                    minimum: '3600',
                    ttl: '3600',
                    xfer: '',
                    also_notify: '',
                    update_acl: '',
                    status: '1',
                  },
              depends_on: nil,
              sidekiq_job_id: nil
            },

            # {
            #   id: SecureRandom.hex,
            #   type: "create_dns_record",
            #   domain: @domain,
            #   data:
            #       {
            #         name: @domain,
            #         type: 'A',
            #         ipv4: ENV['ISPCONFIG_WEB_SERVER_IP'],
            #         ipv6: '',
            #         hosted_zone_id: '',
            #         ttl: 60
            #       },
            #   depends_on: 1,
            #   sidekiq_job_id: nil
            # },

            # {
            #   id: SecureRandom.hex,
            #   type: "create_dns_record",
            #   domain: @domain,
            #   data:
            #       {
            #         name: 'www',
            #         type: 'A',
            #         ipv4: ENV['ISPCONFIG_WEB_SERVER_IP'],
            #         ipv6: '',
            #         hosted_zone_id: '',
            #         ttl: 60
            #       },
            #   depends_on: 1,
            #   sidekiq_job_id: nil
            # },
            # {
            #   id: SecureRandom.hex,
            #   type: "create_dns_record",
            #   domain: @domain,
            #   data:
            #       {
            #         name: @domain,
            #         type: 'NS',
            #         nameserver: ENV['ISPCONFIG_DNS_SERVER_NS1'],
            #         hosted_zone_id: '',
            #         ttl: 3600
            #       },
            #   depends_on: 1,
            #   sidekiq_job_id: nil
            # },
            # {
            #   id: SecureRandom.hex,
            #   type: "create_dns_record",
            #   domain: @domain,
            #   data:
            #       {
            #         name: @domain,
            #         type: 'NS',
            #         nameserver: ENV['ISPCONFIG_DNS_SERVER_NS2'],
            #         hosted_zone_id: '',
            #         ttl: 3600
            #       },
            #   depends_on: 1,
            #   sidekiq_job_id: nil
            # }

          ]
      end

      def prepare_web_domain_task
        @tasks <<
          {
            id: 2,
            type: "create_web_domain",
            domain: @domain,
            user_domain_id: @user_domain.id,
            data: {
              server_type: @server_type,
              ip_address: '',
              ipv6_address: '',
              domain: @domain,
              hd_quota: '-1',
              traffic_quota: '-1',
              subdomain: 'www',
              php: 'y',
              active: 'y'
            },
            depends_on: 1,
            sidekiq_job_id: nil
          }
      end

      def prepare_mail_domain_task
        @tasks <<
          {
            id: 3,
            type: "create_mail_domain",
            domain: @domain,
            user_domain_id: @user_domain.id,
            data: {
              domain: @domain,
              active: 'y'
            },
            depends_on: 1,
            sidekiq_job_id: nil
          }

        # @tasks <<
        #   {
        #     id: SecureRandom.hex,
        #     type: "create_dns_record",
        #     domain: @domain,
        #     data:
        #         {
        #           name: @domain,
        #           type: 'MX',
        #           mailserver: "mail.#{get_sanitized_domain(@domain)}",
        #           hosted_zone_id: '', # needed at later stage
        #           ttl: 60,
        #           priority: 60
        #         },
        #     depends_on: 3,
        #     sidekiq_job_id: nil
        #   }
      end

      def prepare_mail_box_task
        emails = wizard_params[:emails]

        emails.each_with_index do |email, _idx|
          @tasks <<
            {
              id: SecureRandom.hex,
              type: "create_mail_box",
              domain: @domain,
              user_domain_id: @user_domain.id,
              actions: true,
              data: {
                domain_name: @domain,
                mail_domain: @domain,
                email: "#{email}@#{@domain}",
                password: SecureRandom.hex,
                name: '',
                quota: '0',
                cc: "",
                forward_in_lda: '0',
                policy: '5',
                postfix: 'y',
                disablesmtp: 'n',
                disabledeliver: 'n',
                greylisting: 'n',
                disableimap: 'n',
                disablepop3: 'n'
              },
              depends_on: 3,
              sidekiq_job_id: nil
            }
        end
      end

      def prepare_ftp_account_task
        @tasks <<
          {
            id: SecureRandom.hex,
            type: "create_ftp_account",
            domain: @domain,
            user_domain_id: @user_domain.id,
            actions: true,
            data: {
              server_type: @server_type,
              parent_domain_id: '', # needed
              domain: @domain,
              username: set_ftp_username(@domain).first(20),
              password: SecureRandom.urlsafe_base64,
              quota_size: '-1',
              active: 'y',
              uid: '', # needed
              gid: '', # needed
              dir: '' # needed
            },
            depends_on: 2,
            sidekiq_job_id: nil
          }
      end

      def prepare_database_task
        @tasks <<
          {
            id: SecureRandom.hex,
            type: "create_database",
            domain: @domain,
            user_domain_id: @user_domain.id,
            actions: true,
            data: {
              server_type: @server_type,
              web_domain_id: "", # needed in later stage
              database_name: get_database_name(@domain),
              database_username: get_database_user_name(@domain),
              database_password: SecureRandom.hex,
              user_domain_id: @user_domain.id #TODO: To be removed
            },
            depends_on: 2,
            sidekiq_job_id: nil
          }
      end

      def set_ftp_username(domain)
        domain = domain.gsub("www.", '')
        domain = domain.gsub('-', '_')

        domain.gsub!('.', '_')
      end

      def wizard_params
        params.require("wizard").permit(:domain, :server_type, :enable_web_service, :enable_mail_service, :enable_ftp_service, :enable_db_service, emails: [])
      end

      def set_batch_jobs
        @batch_jobs = eval(AppManager::RedisWrapper.get("batch_jobs_user_id_#{current_spree_user.id}").to_s)

        if @batch_jobs.present?
          @batch_jobs = @batch_jobs.with_indifferent_access

          @batch_jobs = @batch_jobs.select do |k,v|
            job = v[0]
            ActiveJob::Status.get(job["sidekiq_job_id"]).present?
          end
        end
      end

      def create_user_domain
        @user_domain = current_spree_user.user_domains.create({domain: @domain})
      end

      def get_database_name(domain)
        domain = domain.gsub("www.", '')
        domain = domain.gsub('-', '_')
        domain = domain.gsub('.', '_')

        domain.to_s
      end

      def get_database_user_name(domain)
        domain = domain.gsub("www.", '')
        domain = domain.gsub('.', '_')

        domain.to_s
      end

      def get_sanitized_domain(domain)
        domain.gsub("www.", '')
      end

      def valid_domain?(domain)
         flag = VALID_DOMAIN_REGEX.match?(@domain)

         flag && reserved_domain_check(domain)
      end

      def reserved_domain_check(domain)
        valid = true

        valid = false if OpspiHelper.reserved_domains.include?(domain)
        
        # matching the subdomain of reserved domain
        OpspiHelper.reserved_domains.each do |reserved_domain|
          valid = false if Regexp.new("\\/*.#{reserved_domain}").match?(domain)
        end

        unless valid
          @error = I18n.t("wizards.domain_not_allowed") 
        end

        return valid
      end

      # def redirect_to_index
      #   unless domain_limit_exceed_check
      #     redirect_to admin_wizards_path
      #   end
      # end

    end
  end
end
