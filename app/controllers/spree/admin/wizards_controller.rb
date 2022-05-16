# frozen_string_literal: true

module Spree
  module Admin
    class WizardsController < Spree::Admin::BaseController
      def index; end
      def new; end

      def create
        @domain = wizard_params[:domain]
        @tasks = []

        build_tasks

        pp @tasks

        TaskManager::TaskProcessor.new(current_spree_user, @tasks.flatten).call

        flash[:success] = "Wizard Jobs Started. Your services will be activated in few miniutes"

        redirect_to admin_wizards_path
      end

      private

      def build_tasks
        prepare_dns_task

        if wizard_params[:enable_web_service] == 'y'
          prepare_web_domain_task
          prepare_ftp_account_task
        end

        if wizard_params[:enable_mail_service] == 'y'
          prepare_mail_domain_task
          prepare_mail_box_task
        end
      end

      def prepare_dns_task
        @tasks <<
          [
            {
              id: 1,
              type: "create_dns_domain",

              data:
                  {
                    name: @domain,
                    mbox: 'webmaster.example.com.',
                    refresh: '7200',
                    retry: '540',
                    expire: '604800',
                    minimum: '3600',
                    ttl: '3600',
                    xfer: '',
                    also_notify: '',
                    update_acl: '',
                    status: '1'
                  },
              depends_on: nil,
              sidekiq_job_id: nil
            },

            {
              id: 20,
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
              id: 21,
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
            }

          ]
      end

      def prepare_web_domain_task
        @tasks <<
          {
            id: 2,
            type: "create_web_domain",
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
            data: {
              domain: @domain,
              active: 'y'
            },
            depends_on: nil,
            sidekiq_job_id: nil
          }
      end

      def prepare_mail_box_task
        emails = wizard_params[:emails]

        emails.each_with_index do |email, idx|
          @tasks <<
            {
              id: @tasks.size + idx,
              type: "create_mail_box",
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
            id: @tasks.size + 1,
            type: "create_ftp_account",
            domain: @domain,
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

      def set_ftp_username(domain)
        domain = domain.gsub("www.", '')

        domain.gsub!('.', '_')
      end

      def wizard_params
        params.require("wizard").permit(:domain, :enable_web_service, :enable_mail_service, emails: [])
      end
    end
  end
end
