module CustomValidator 

  def self.validate(data, reg)
    matchers = data.match(reg)
    
    return [false] if matchers.blank?

    return [true]
  end
end