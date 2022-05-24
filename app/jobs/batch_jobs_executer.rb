# frozen_string_literal: true
require 'concerns/session_notifications'

class BatchJobsExecuter < ApplicationJob
  queue_as :default

  include ActiveJob::Status
  include SessionNotifications

  def perform(user_id, parent_task_id, data)
    initialize_variables(user_id, parent_task_id, data)

    if can_execute_now?
      Rails.logger.info {  "----------- #{service_class.name} Started--------" }
      process
      Rails.logger.info {  "----------- #{service_class.name} Completed--------" }
    else
      Rails.logger.info {  "----------- Putting back in Queue #{service_class.name}--------" }
      
      raise StandardError.new 'Parent Job not yet completed'
    end
  end

  def process
    service_object = service_class.new(@user, @data)
    service_object.call

    unless service_object.success?
      status.update(error: true, message: service_object.response[:message])

      send_background_notification(@user.id, nil, "Unable to process #{service_object.class} at this time. #{service_object.response[:message]}")
      raise StandardError.new 'Unable to process at this time.'
    end

    send_background_notification(@user.id, "#{service_object.class} task completed", nil)
  end

  private

  def send_background_notification(user_id, message, error)
    session = {
      user_id: user_id,
    }

    status = ActiveJob::Status.get(self.job_id)[:status]
    status = 'completed' if error.blank?

    data = {
      message: message,
      job_id: self.job_id,
      job_status: status,

    }

    if ['create_mail_box', 'create_ftp_account'].include?(@data[:type])
      data[:actions] = true
    else
      data[:actions] = false
    end

    notify_session!(session, data, error)
  end

  def can_execute_now?
    return true if @parent_task_id.blank?

    parent_task_completed?
  end

  def parent_task_completed?
    status = ActiveJob::Status.get(@parent_task_id)


    status.completed?
  end

  def initialize_variables(user_id, parent_task_id, data)
    @user       = Spree::User.find_by_id(user_id)
    @parent_task_id = parent_task_id
    @data           = data
  end

  def service_class
    case @data[:type]
    when 'create_dns_domain'
      TaskManager::HostingPanelTasks::DnsDomainTask
    when 'create_dns_record'
      TaskManager::HostingPanelTasks::DnsRecordTask
    when 'create_web_domain'
      TaskManager::HostingPanelTasks::WebDomainTask
    when 'create_mail_domain'
      TaskManager::HostingPanelTasks::MailDomainTask
    when 'create_mail_box'
     TaskManager::HostingPanelTasks::MailBoxTask
    when 'create_ftp_account'
      TaskManager::HostingPanelTasks::FtpAccountTask
    when 'create_database'
      TaskManager::HostingPanelTasks::DatabaseTask
    else
      raise StandardError, "Unknown task type"
    end
  end
end