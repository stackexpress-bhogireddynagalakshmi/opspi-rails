# frozen_string_literal: true

class ApplicationController < ActionController::Base
  set_current_tenant_by_subdomain_or_domain(:account, :subdomain, :domain)

  helper_method [:get_tenant_host_for_resource_path]

  include Tenantable

  before_action do
    set_tenant
  end

  def ensure_user_confirmed
    return nil if current_spree_user.confirmed?
    
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html do 
          
        render 'spree/shared/not_confirmed'
       end
      format.js { head :forbidden, content_type: 'text/js' }
    end
  end
  
  def set_user_domain
    @user_domain = current_spree_user.user_domains.find(params[:user_domain_id])
  end

  def ensure_hosting_panel_access

    return nil if current_spree_user.isp_config_id.present? || current_spree_user.solid_cp_id.present?

    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html do 
          
        render 'spree/shared/access_denied'
       end
      format.js { head :forbidden, content_type: 'text/js' }
    end
  end
end
