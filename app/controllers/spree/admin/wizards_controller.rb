# frozen_string_literal: true

module Spree
  module Admin
    class WizardsController < Spree::Admin::BaseController
      include ApisHelper
      
      before_action :set_batch_jobs, only: %i[index show]
      before_action :ensure_hosting_panel_access

      def index; end
      def new; end

      def create
        @domain = wizard_params[:domain]

        if VALID_DOMAIN_REGEX.match?(@domain)
          @tasks = []
          
          build_tasks
          
          TaskManager::TaskProcessor.new(current_spree_user, @tasks).call
          
          flash[:success] = "Wizard Jobs Started. Your services will be activated in few miniutes"
          
          set_batch_jobs

          redirect_to admin_wizard_path(id: @batch_jobs.keys.last)
        else
          @error = 'Invalid domain name'
          render 'new'
        end
      end

      def show
        @tasks = @batch_jobs[params[:id]] || @batch_jobs[params[:id].to_i]
      end

      def reset_password
        @password = SecureRandom.hex
        case params[:type]
        when 'create_mail_box'
          mailboxes = mail_user_api.all
          mailboxes = mailboxes[:response].response
          mailbox   = mailboxes.detect { |x| x.email == params[:email] }
          @response = mail_user_api.update(mailbox.mailuser_id, { password: @password })
        when 'create_ftp_account'
          ftp_users = ftp_user_api.all
          ftp_users = ftp_users[:response].response
          ftp_user  = ftp_users.detect { |x| x.username == params[:email] }
          @response = ftp_user_api.update(ftp_user.ftp_user_id, { password: @password })
        when 'create_database'
          db_users  = db_user_api.all
          db_users  = db_users[:response].response
          db_user   = db_users.detect { |x| x.database_user == "c6_#{params[:email]}" }
          @response = db_user_api.update_database_user_password(
            db_user.database_user_id, { database_password: @password }
            )
        end

      rescue => e
        Rails.logger.error { e.message }
        puts e.backtrace
        @response = {success: false, error: "something went wrong. Please try after sometime."}
      end

      private

      def build_tasks
        prepare_dns_task
        if wizard_params[:enable_web_service] == 'y'
          prepare_web_domain_task
          prepare_ftp_account_task
        end

        if wizard_params[:enable_db_service] == 'y'
          prepare_database_task
        end

        if wizard_params[:enable_mail_service] == 'y'
          prepare_mail_domain_task

          prepare_mail_box_task
        end

        @tasks = @tasks.flatten
      end

      def prepare_dns_task
        @tasks <<
          [
            {
              id: 1,
              type: "create_dns_domain",
              domain: @domain,
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

            {
              id: SecureRandom.hex,
              type: "create_dns_record",
              domain: @domain,
              data:
                  {
                    name: @domain,
                    type: 'A',
                    ipv4: ENV['ISPCONFIG_WEB_SERVER_IP'],
                    ipv6: '',
                    hosted_zone_id: '',
                    ttl: 60
                  },
              depends_on: 1,
              sidekiq_job_id: nil
            },

            {
              id: SecureRandom.hex,
              type: "create_dns_record",
              domain: @domain,
              data:
                  {
                    name: 'www',
                    type: 'A',
                    ipv4: ENV['ISPCONFIG_WEB_SERVER_IP'],
                    ipv6: '',
                    hosted_zone_id: '',
                    ttl: 60
                  },
              depends_on: 1,
              sidekiq_job_id: nil
            },
            {
              id: SecureRandom.hex,
              type: "create_dns_record",
              domain: @domain,
              data:
                  {
                    name: @domain,
                    type: 'NS',
                    nameserver: ENV['ISPCONFIG_DNS_SERVER_NS1'],
                    hosted_zone_id: '',
                    ttl: 3600
                  },
              depends_on: 1,
              sidekiq_job_id: nil
            },
            {
              id: SecureRandom.hex,
              type: "create_dns_record",
              domain: @domain,
              data:
                  {
                    name: @domain,
                    type: 'NS',
                    nameserver: ENV['ISPCONFIG_DNS_SERVER_NS2'],
                    hosted_zone_id: '',
                    ttl: 3600
                  },
              depends_on: 1,
              sidekiq_job_id: nil
            }

          ]
      end

      def prepare_web_domain_task
        @tasks <<
          {
            id: 2,
            type: "create_web_domain",
            domain: @domain,
            data: {
              server_type: 'linux',
              ip_address: '',
              ipv6_address: '',
              domain: @domain,
              hd_quota: '-1',
              traffic_quota: '-1',
              subdomain: 'www',
              php: 'y',
              active: 'y'
            },
            depends_on: nil,
            sidekiq_job_id: nil
          }
      end

      def prepare_mail_domain_task
        @tasks <<
          {
            id: 3,
            type: "create_mail_domain",
            domain: @domain,
            data: {
              domain: @domain,
              active: 'y'
            },
            depends_on: nil,
            sidekiq_job_id: nil
          }

        @tasks <<
          {
            id: SecureRandom.hex,
            type: "create_dns_record",
            domain: @domain,
            data:
                {
                  name: @domain,
                  type: 'MX',
                  mailserver: "mail.#{get_sanitized_domain(@domain)}",
                  hosted_zone_id: '', # needed at later stage
                  ttl: 60,
                  priority: 60
                },
            depends_on: 3,
            sidekiq_job_id: nil
          }
      end

      def prepare_mail_box_task
        emails = wizard_params[:emails]

        emails.each_with_index do |email, _idx|
          @tasks <<
            {
              id: SecureRandom.hex,
              type: "create_mail_box",
              domain: @domain,
              actions: true,
              data: {
                domain_name: @domain,
                mail_domain: @domain,
                email: "#{email}@#{@domain}",
                password: SecureRandom.hex,
                name: 'Test',
                quota: '0',
                cc: "user2@#{@domain}",
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
            actions: true,
            data: {
              server_type: 'linux',
              parent_domain_id: '', # needed
              username: set_ftp_username(@domain),
              password: SecureRandom.hex,
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
            actions: true,
            data: {
              web_domain_id: "", # needed in later stage
              database_name: get_database_name(@domain),
              database_username: get_database_user_name(@domain),
              database_password: SecureRandom.hex
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
        params.require("wizard").permit(:domain, :enable_web_service, :enable_mail_service, :enable_db_service, emails: [])
      end

      def set_batch_jobs
        @batch_jobs = eval(AppManager::RedisWrapper.get("batch_jobs_user_id_#{current_spree_user.id}").to_s)

        @batch_jobs = @batch_jobs.with_indifferent_access if @batch_jobs.present?

        @batch_jobs
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
    end
  end
end
