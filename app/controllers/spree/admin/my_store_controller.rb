class Spree::Admin::MyStoreController < Spree::Admin::BaseController
  helper Spree::Admin::NavigationHelper

  def index
    @store = current_store
  end

  def update
    @store = current_store
    validation = StoreManager::StoreDomainValidator.new(params[:custom_domain],current_store: current_store).call

    if validation[0] == true
      dns_resolver = DnsManager::CnameResolver.new(params[:custom_domain])
      if dns_resolver.cname_configured?
        current_store.url = params[:custom_domain]
        current_store.save
      else
        @store.errors.add(:url, "Please add #{ENV['ADMIN_DOMAIN'] } as CNAME in your DNS setting." )
      end
    else
      @store.errors.add(:url, validation[1])
    end
    render "index"
  end
  
end
