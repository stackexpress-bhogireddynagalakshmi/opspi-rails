module Spree
	 	module  Gateway::PayPalExpressDecorator
	 		 def provider
		      ::PayPal::SDK.configure(
		        :mode      => preferred_server.present? ? preferred_server : "sandbox",
		        :username  => preferred_login,
		        :password  => preferred_password,
		        :signature => preferred_signature,
		        :ssl_options => { :ca_file => nil }
		        )
		      provider_class.new
		    end
	 	end
end

::Spree::Gateway::PayPalExpress.prepend Spree::Gateway::PayPalExpressDecorator if ::Spree::Gateway::PayPalExpress.included_modules.exclude?(Spree::Gateway::PayPalExpressDecorator)



