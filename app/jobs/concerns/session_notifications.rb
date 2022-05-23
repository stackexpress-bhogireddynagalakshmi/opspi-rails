# frozen_string_literal: true

# WebSocket notifications for ActiveJob
module SessionNotifications
  extend ActiveSupport::Concern

  def notify_session!(session, data, error = nil)
    return if session.blank?

    if error.present?
      data.merge!({
        status:  :error,
        message: error
      })
    end

    ActionCable.server.broadcast target_channel(session), data

  rescue StandardError => e
    Rails.logger.error { "Failed to notify session (#{session}): #{e.message}" }
  end

  def target_channel(session)
    "notifications:#{session[:user_id]}"
  end
end
