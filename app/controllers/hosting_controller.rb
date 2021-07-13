class HostingController < Spree::StoreController
	# layout 'spree/layouts/spree_application'
	include Spree::CacheHelper

	def servers
		@products = current_store.try(:account).try(:spree_products) 
		if params[:slug] == 'vps'
		elsif params[:slug] == 'linux-servers'
			@products = @products.linux
		elsif params[:slug] == 'windows-servers'
			@products = @products.windows
		end	

		render 'servers'
	end
end
