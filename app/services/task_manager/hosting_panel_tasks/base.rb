module TaskManager
  module HostingPanelTasks
    class Base < ApplicationService
      attr_reader :user, :task, :success, :response
      def initialize(user, task)
        @user = user
        @task = task
        @data = @task[:data]
        @success = false
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