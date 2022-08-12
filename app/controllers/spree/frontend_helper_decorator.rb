module Spree
    module FrontendHelperDecorator
        def class_for(flash_type)
            {
              success: 'success',
              registration_error: 'danger',
              error: 'danger',
              alert: 'danger',
              warning: 'warning',
              notice: 'success'
            }[flash_type.to_sym]
          end
    
          def flash_messages(opts = {})
          flashes = ""
          excluded_types = opts[:excluded_types].to_a.map(&:to_s)
    
          flash.to_h.except('order_completed').each do |msg_type, text|
            next if msg_type.blank? || excluded_types.include?(msg_type)
            
            flashes << content_tag(:div, class: "alert alert-#{class_for(msg_type)} mb-4") do
              content_tag(:button, '&times;'.html_safe, class: 'close-button x-button', data: { dismiss: 'alert', hidden: true }) +
                content_tag(:span, text)
            end
          end
          flashes.html_safe
        end
    end
  end
  
  if ::Spree::FrontendHelper.included_modules.exclude?(Spree::FrontendHelperDecorator)
    ::Spree::FrontendHelper.prepend Spree::FrontendHelperDecorator
  end
  