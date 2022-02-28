# frozen_string_literal: true

class TimeProvider
  TIME_ZONES = {
    utc: "UTC",
    est: "Eastern Time (US & Canada)"
  }.freeze

  def initialize(default_time_zone = nil, start_time = nil)
    @time_zone = default_time_zone || :est
    @start_time = start_time.to_datetime if start_time

    @instance_created_at = DateTime.now if @start_time.present?
  end

  def now
    current_time = DateTime.now

    if @start_time.present?
      # current time is start time plus whatever has elapsed since we created this instance
      current_time = @start_time + (current_time - @instance_created_at)
    end

    current_time.in_time_zone(TIME_ZONES[@time_zone])
  end

  def today
    now.to_date
  end

  def self.now
    new.now
  end

  def self.today
    new.today
  end

  def self.current_period
    today = self.today
    today.beginning_of_month..today.end_of_month
  end
end
