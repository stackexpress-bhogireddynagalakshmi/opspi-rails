module Spree
	module Admin
	    module StoresControllerDecorator
	      def self.prepended(base)
	        # base.before_action :check_tanent, only: :edit
	      end

	      # def check_tanent
	      # 	if current_tenant.present? && current_tenant.id  != params[:id].to_i
		     #  	flash[:error] = 'Athuorization Failed'
		     #  	redirect_to :admin_stores 
	      # 	end
	      # end

	      def account_link
	      	byebug
	      end
	      
	    end
	 end
end

::Spree::Admin::StoresController.prepend Spree::Admin::StoresControllerDecorator if ::Spree::Admin::StoresController.included_modules.exclude?(Spree::Admin::StoresControllerDecorator)
