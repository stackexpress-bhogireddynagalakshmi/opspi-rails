module Spree
	module  BaseMailerDecorator		
		
    def from_address
      ENV['MAIL_FROM']
    end

    def mail(headers = {}, &block)
  		headers = ensure_from_and_cc_added_to_email(headers)		
  		super
  	end

  	def ensure_from_and_cc_added_to_email(headers)
  		return headers if headers.blank?
  		
      if ENV['OVERRIDE_MAIL_RECEIVER']
  		  headers[:to] = [ENV['CC_EMAIL1'],ENV['CC_EMAIL2']]
      else
        headers[:bcc] = [ENV['CC_EMAIL1'],ENV['CC_EMAIL2']]
      end

  		headers[:from] = ENV['MAIL_FROM']
  		return headers
  	end
	end
end

::Spree::BaseMailer.prepend Spree::BaseMailerDecorator if ::Spree::BaseMailer.included_modules.exclude?(Spree::BaseMailerDecorator)





