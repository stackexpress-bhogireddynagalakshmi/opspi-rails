# frozen_string_literal: true

module TaskManager
  class TaskScheduler < ApplicationService
    attr_reader :current_task, :user, :parent_job_id

    def initialize(current_task, user_id, parent_job_id)
      @current_task  = current_task
      @user          = Spree::User.find(user_id)
      @parent_job_id = parent_job_id
    end

    def call
      current_job = if parent_job_id.present?
                      ::BatchJobsExecuter.set(wait: 3.second).perform_later(user.id, parent_job_id, current_task)
                    else
                      ::BatchJobsExecuter.perform_later(user.id, parent_job_id, current_task)
                    end

      Rails.logger.info { "scheduled #{current_task[:id]} -- #{current_task[:type]}:#{current_job.job_id} || parent_job: #{parent_job_id || 'nil'}" }

      current_job
    end
  end
end
