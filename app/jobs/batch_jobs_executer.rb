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
      retry_job wait: 10.seconds
    end
  end

  def process
    service_object = service_class.new(@user, @data)
    service_object.call

    unless service_object.success?
      send_background_notification(user_id, nil, "Unable to process #{service_object.class} at this time.")
      raise StandardError.new 'Unable to process at this time.'
    end

    send_background_notification(user_id, "#{service_object.class} task completed", nil)
  end

  private

  def send_background_notification(user_id,message, error)
    session = {
      user_id: user_id,
    }

    data = {
      message: message
    }

    notify_session!(session, data, nil)
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
    else
      raise StandardError, "Unknown task type"
    end
  end
end