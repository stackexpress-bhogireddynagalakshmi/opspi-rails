module TaskManager
  module HostingPanelTasks
    class Base < ApplicationService
      attr_reader :user, :task
      def initialize(user, task)
        @user = user
        @task = task
      end
      
      def success?
        true
      end
    end
  end
end