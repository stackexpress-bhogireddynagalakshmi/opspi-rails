module Tenantable
  extend ActiveSupport::Concern

  def get_tenant_host_for_resource_path(resource)
    [request.protocol,resource.account.domain,":#{request.port}"].join
  end

  
  def set_tenant
    if DomainCheck.check_domain(request)

      ActsAsTenant.current_tenant = Account.where('subdomain = ? or domain = ?',request.host,request.host).first
      ActsAsTenant.current_tenant = nil if current_spree_user&.superadmin?
    else
      render :json=>'Sorry, this domain is currently unavailable.'
    end
  end

  private

  class DomainCheck
    def self.check_domain request
      whitelisted_domains = Spree::Store.pluck(:url) + [OpspiHelper.admin_domain] + Account.pluck(:subdomain)
        whitelisted_domains.include? (request.host)
      end
  end 
end

