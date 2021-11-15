class HostingController < Spree::StoreController
	# layout 'spree/layouts/spree_application'
	include Spree::CacheHelper

	def servers
		@products = current_store.try(:account).try(:spree_products).where(subscribable: true)
		if params[:slug] == 'vps'
		elsif params[:slug] == 'linux-servers'
			@products = @products.linux
		elsif params[:slug] == 'windows-servers'
			@products = @products.windows
		end	

		render 'servers'
	end


  def register_domain

  end

  def search_domain
    domains = params[:domian_names].split(",")
    tlds    = params[:tlds]
  
    @response = ResellerClub::Domain.available("domain-name" => domains,"tlds" => tlds)

    @suggestions =  ResellerClub::Domain.v5_suggest_names("keyword" => params[:domian_names], "tlds" => tlds, "hyphen-allowed" => "true", "add-related" => "true", "no-of-results" => "10")

    

  end
end
