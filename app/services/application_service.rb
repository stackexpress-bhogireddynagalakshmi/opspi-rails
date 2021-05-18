# frozen_string_literal: true

class ApplicationService
  def self.call(*args, &block)
    new(*args, &block).call
  end

   class MethodNotImplemented < StandardError; end
   class WrongDataPassed < StandardError; end
   class NonCallablePassedToRun < StandardError; end
   class IncompatibleParamsPassed < StandardError; end

   
end

