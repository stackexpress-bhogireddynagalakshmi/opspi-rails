class ErrorLogger
  def self.log_exception(err)
    Rails.logger.error do
       ActiveSupport::LogSubscriber.new.send(:color, error_lines(err) , :red)
    end
  end

  def self.error_lines(err)
    "#{err.class.name} : #{err.message}\n  #{err.backtrace.first(15).join("\n  ")}"
  end
end