class Spree::Admin::MyStoreController < Spree::Admin::BaseController
  helper Spree::Admin::NavigationHelper

  def index
    @store = current_store
  end

  def update
    @store = current_store
    if params[:custom_domain].present?
      validation = StoreManager::StoreDomainValidator.new(params[:custom_domain],current_store: current_store).call
      if validation[0] == true
        dns_resolver = DnsManager::CnameResolver.new(params[:custom_domain])
        if dns_resolver.cname_configured?
          current_store.url = params[:custom_domain]
          if current_store.save
            @store.update(store_params)
          end
        else
          @store.errors.add(:url, I18n.t('my_store.cname_not_added',cname: ENV['CNAME_POINTER_DOMAIN']) )
        end
      else
        @store.errors.add(:url, validation[1])
      end
    else
      @store.update(store_params)
    end
    render "index"
  end

  private
  def store_params
    params.require(:store).permit(:logo,:mailer_logo,:name)
  end

end
