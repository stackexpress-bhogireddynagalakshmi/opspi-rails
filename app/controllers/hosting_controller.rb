class HostingController < Spree::StoreController
	# layout 'spree/layouts/spree_application'
	include Spree::CacheHelper

	def index
		
	end

	def servers
		@products = current_store.try(:account).try(:spree_products) 
		if params[:slug] == 'vps'
			render 'servers'
		elsif params[:slug] == 'linux-servers'
			@products = @products.linux
			render 'servers'
		elsif params[:slug] == 'windows-servers'
			@products = @products.windows
			render 'servers'
		else
			render 'default'
		end	
	end
end
