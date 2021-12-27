module Spree
	module CounrtyDecorator
    
        def country_name_dialing_code
            code = IsoCountryCodes.find(iso)
            "#{iso_name} (#{code.calling})"
        end
	end
end

::Spree::Country.prepend Spree::CounrtyDecorator if ::Spree::Country.included_modules.exclude?(Spree::CounrtyDecorator)

