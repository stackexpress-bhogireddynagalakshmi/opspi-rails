class DeviseCustomMailer < Devise::Mailer   
  helper :application # gives access to all helpers defined within `application_helper`.
  
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
         
  
 
  #layout 'mailer'

  def confirmation_instructions(record, token, opts={})
    super
  end

end
