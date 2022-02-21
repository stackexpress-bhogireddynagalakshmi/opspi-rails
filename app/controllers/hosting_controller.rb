# frozen_string_literal: true

class HostingController < Spree::StoreController
  # layout 'spree/layouts/spree_application'
  include Spree::CacheHelper
  include Spree::Core::ControllerHelpers
  include Spree::Core::ControllerHelpers::Store
  helper Spree::Core::Engine.helpers

  def servers
    @products = current_store.try(:account).try(:spree_products).where(subscribable: true)
    case params[:slug]
    when 'vps'
    when 'linux-servers'
      @products = @products.linux
    when 'windows-servers'
      @products = @products.windows
    end

    render 'servers'
  end

  def register_domain; end

  def search_domain
    domains = params[:domian_names].split(",")
    tlds    = params[:tlds]
    @product = Spree::Product.domain.first

    @response = ResellerClub::Domain.available("domain-name" => domains, "tlds" => tlds)

    @suggestions = ResellerClub::Domain.v5_suggest_names("keyword" => params[:domian_names], "tlds" => tlds,
                                                         "hyphen-allowed" => "true", "add-related" => "true", "no-of-results" => "10")
  end
end
