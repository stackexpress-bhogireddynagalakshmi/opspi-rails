# frozen_string_literal: true

module TaskManager
  class TaskProcessor < ApplicationService
    def initialize(user, tasks)
      @user           = user
      @tasks          = tasks
    end

    def call
      parent_jobs = @tasks.select { |x| x[:depends_on].nil? }
      parent_jobs.each do |parent_job|
        dependendent_jobs = @tasks.select { |x| x[:depends_on] == parent_job[:id] }
        schedule_tasks(parent_job, dependendent_jobs)
      end

      save_to_redis
    end

    private

    def schedule_tasks(current_task, tasks)
      parent = @tasks.detect { |x| x[:id] == current_task[:depends_on] }
      parent_job_id = begin
        parent[:sidekiq_job_id]
      rescue StandardError
        nil
      end

      current_job = TaskManager::TaskScheduler.new(current_task, @user.id, parent_job_id).call

      current_task[:sidekiq_job_id] = current_job.job_id

      return nil if tasks.size.zero?

      current_task = tasks.pop
      dependent_tasks = @tasks.select { |x| x[:depends_on] == current_task[:id] }

      if dependent_tasks.present?
        schedule_tasks(current_task, dependent_tasks)
      else
        schedule_tasks(current_task, tasks)
      end
    end

    def save_to_redis
      batch_jobs =  eval(AppManager::RedisWrapper.get("batch_jobs_user_id_#{@user.id}").to_s)
      if batch_jobs.blank?
        batch_jobs = {}.with_indifferent_access
        batch_jobs["1"] = @tasks
      else
        batch_jobs[batch_jobs.size + 1] = @tasks
      end

      AppManager::RedisWrapper.set("batch_jobs_user_id_#{@user.id}", batch_jobs)
    end
  end
end