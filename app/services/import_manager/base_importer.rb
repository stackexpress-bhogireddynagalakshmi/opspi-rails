module ImportManager
  class BaseImporter  < ApplicationService
    attr_reader :file

    def initialize(file,options={})
      @file = file
    end
    
  end
end