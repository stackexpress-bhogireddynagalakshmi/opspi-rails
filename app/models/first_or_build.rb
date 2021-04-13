module FirstOrBuild
  def first_or_build(attributes = {})
  	where(attributes).first || build(attributes)
  end
end

