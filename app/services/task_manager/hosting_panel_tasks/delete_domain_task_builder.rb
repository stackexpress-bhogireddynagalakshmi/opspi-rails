module TaskManager
  module HostingPanelTasks
    class DeleteDomainTaskBuilder
      
    def initialize(user, options = {})
      @user = user
      @user_domain = UserDomain.find(options[:user_domain_id])
    end

    def call
      @tasks = []
          
      build_tasks
      byebug

      TaskManager::TaskProcessor.new(@user, @tasks).call
    end

    private
    def build_tasks
      prepare_delete_website_task
      prepare_delete_ftp_users_task
      prepare_delete_mailboxes_task
      prepare_delete_mail_domain_task
      prepare_delete_mailing_lists_task
      prepare_delete_mail_forwads_task
      prepare_delete_spamfilter_task
      prepare_delete_user_domain_task

      @tasks = @tasks.flatten
    end

    def prepare_delete_website_task
      
      @tasks <<
        {
          id: SecureRandom.hex,
          type: "delete_web_domain",
          user_domain_id: @user_domain.id,
          data: delete_website_params,
          depends_on: nil,
          sidekiq_job_id: nil
        }
    end

    def prepare_delete_ftp_users_task
      @user_domain.user_ftp_users.each do |object|
      @tasks <<
        {
          id: SecureRandom.hex,
          type: "delete_ftp_account",
          user_domain_id: @user_domain.id,
          data: {
            id: object.id
          },
          depends_on: nil,
          sidekiq_job_id: nil
        }
      end
    end

    def prepare_delete_mail_domain_task
       @tasks <<
          {
            id: SecureRandom.hex,
            type: "delete_mail_domain",
            user_domain_id: @user_domain.id,
            data: {
              id: @user_domain.user_mail_domain.id
            },
            depends_on: nil,
            sidekiq_job_id: nil
          }

    end

    def prepare_delete_mailboxes_task
      @user_domain.user_mailboxes.each do |object|
        @tasks <<
          {
            id: SecureRandom.hex,
            type: "delete_mail_box",
            user_domain_id: @user_domain.id,
            data: {
              id: object.id
            },
            depends_on: nil,
            sidekiq_job_id: nil
          }
      end
    end


    def prepare_delete_mailing_lists_task
      @user_domain.user_mailing_lists.each do |object|
        @tasks <<
          {
            id: SecureRandom.hex,
            type: "delete_mailing_list",
            user_domain_id: @user_domain.id,
            data: {
              id: object.id
            },
            depends_on: nil,
            sidekiq_job_id: nil
          }
        end
    end

    def prepare_delete_mail_forwads_task
      @user_domain.user_mail_forwards.each do |object|
      @tasks <<
        {
          id: SecureRandom.hex,
          type: "delete_mail_forward",
          user_domain_id: @user_domain.id,
          data: {
            id: object.id
          },
          depends_on: nil,
          sidekiq_job_id: nil
        }
    end

    def prepare_delete_spamfilter_task
      @user_domain.user_spam_filters.each do |object|
        @tasks <<
          {
            id: SecureRandom.hex,
            type: "delete_spam_filter",
            user_domain_id: @user_domain.id,
            data: {
              id: object.id
            },
            depends_on: nil,
            sidekiq_job_id: nil
          }
      end
    end

    def prepare_delete_user_domain_task
      @tasks <<
        {
          id: SecureRandom.hex,
          type: "delete_dns_domain",
          user_domain_id: @user_domain.id,
          data: {
            id: @user_domain.id
          },
          depends_on: nil,
          sidekiq_job_id: nil
        }
      end
    end

    def delete_website_params
      if @user_domain.windows?
        @all_domains = begin
          @all_domains = @user.solid_cp.web_domain.all.body[:get_domains_response][:get_domains_result][:domain_info]  
        rescue Exception => e
          []
        end      
        byebug  
        current_domains = @all_domains.collect { |x| x if x[:domain_name].include?(@user_domain.domain) }.compact
        domain_id = current_domains.collect { |c| c[:domain_id] if c[:web_site_id].to_i.zero? }.compact.first
        website_id = current_domains.collect { |c| c[:web_site_id] if c[:web_site_id].to_i.positive? }.compact.first
        byebug
        { web_site_id: website_id, web_domain_id: domain_id, server_type: 'windows' }
      else
        { id: @user_domain.user_website.id, server_type: 'linux'  }
      end
    end


   end
  end
end