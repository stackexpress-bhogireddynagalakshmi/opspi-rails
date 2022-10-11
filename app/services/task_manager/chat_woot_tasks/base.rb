module TaskManager
  module ChatWootTasks
    class Base < ApplicationService
      attr_reader :user, :task, :user_domain, :success, :response
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
        @data[:store]
      end
    end
  end
end