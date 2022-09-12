module TaskManager
  module HostingPanelTasks
    class Base < ApplicationService
      attr_reader :user, :task, :user_domain, :success, :response
      def initialize(user, task)
        @user = user
        @task = task
        @data = @task[:data]
        @success = false
        @user_domain = UserDomain.find(@task[:user_domain_id]) rescue nil
      end
      
      def success?
        return @response[:success]
      end

      def resource_params
        @data
      end
    end
  end
end