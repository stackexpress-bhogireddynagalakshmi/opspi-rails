require 'concerns/session_notifications'

class AlertJob < ApplicationJob
  queue_as :default
  include SessionNotifications

  def perform(*args)
    session = {
      user_id: Spree::User.last.id,
    }

    data = {
       message: "Job completed Successfully"
    }

    notify_session!(session, data, nil)
  end
end
