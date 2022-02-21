# frozen_string_literal: true

module IspConfig
  class Template < Base
    attr_accessor :user

    def initialize(user)
      @user = user
    end

    def all
      response = query({
                         endpoint: '/json.php?client_templates_get_all',
                         method: :GET,
                         body: { client_id: 1, params: {} }
                       })
      if response.code == "ok"
        { success: true, message: 'IspConfig user account updated successfully', response: response }
      else
        msg = "Something went wrong while creating user account. IspConfig Error: #{response.message}"
        { success: false, message: msg, response: response }
      end
    end

    def self.find(id); end

    def create; end

    def update; end

    def destroy; end

    def subscribe; end

    def master_template_dropdown
      plans = all[:response].response

      plans = if user.superadmin?
                plans.select { |x| x.sys_userid == "1" }
              else
                plans.select { |x| x.sys_userid == user.isp_config_id }
              end
      plans = plans.pluck(:template_name, :template_id)
    rescue Exception => e
      plans = []
    end
  end
end
