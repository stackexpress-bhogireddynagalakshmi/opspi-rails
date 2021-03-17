class HostingController < Spree::StoreController
	# layout 'spree/layouts/spree_application'
	include Spree::CacheHelper

	def index
		
	end

	def hosting_page
		@products = current_store.try(:account).try(:spree_products) 
		begin
			if params[:slug] == 'shared-hosting'
			@products = @products.where(plan_type: 'SHARED_HOSTING')

			elsif params[:slug] == 'vps-hosting'
				@products = @products.where(plan_type: 'VPS_HOSTING')
			elsif params[:slug] == 'dedicated-hosting'
				@products = @products.where(plan_type: 'DEDICATED_HOSTING')
			else

			end			
		rescue Exception => e
			@products = []
		end		
	end

	def servers

		if params[:slug] == 'vps'
			render 'servers'
		elsif params[:slug] == 'linux-dedicated-servers'
			render 'servers'
		elsif params[:slug] == 'windows-dedicated-servers'
			render 'servers'
		else
			render 'default'
		end	
	end
end
