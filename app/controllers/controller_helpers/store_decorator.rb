
module ControllerHelpers
    module StoreDecorator

      def current_store
        @current_store ||= current_store_finder.new(url: request.env['SERVER_NAME']).execute
      end

      def current_store_finder
        CustomStoreFinder
      end

    end
 end


::Spree::Core::ControllerHelpers::Store.prepend ::ControllerHelpers::StoreDecorator if ::Spree::Core::ControllerHelpers::Store.included_modules.exclude?(::ControllerHelpers::StoreDecorator)
