module TenantManager
	class TenantServiceExecutor
		attr_reader :resource,:service_executed

		def initialize(resource,options = {})
  			@resource = resource
  		end

  		def call
  			return if resource.blank?
  			return unless TenantManager::TenantHelper.current_admin_tenant?


  			tenant_service = TenantService.find_by({user_id: resource.id})
  			return if tenant_service.blank? || tenant_service.service_executed?


  			
  			TenantManager::UserTenantUpdater.new(tenant_service.user,tenant_service.account_id).call
  			TenantManager::StoreTenantUpdater.new(tenant_service.user,tenant_service.account_id).call

  			tenant_service.update(service_executed: true)

  			@service_executed = tenant_service.service_executed


  			tenant_service
  		end
	end
end