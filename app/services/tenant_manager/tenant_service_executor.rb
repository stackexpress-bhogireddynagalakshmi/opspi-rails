module TenantManager
  class TenantServiceExecutor
    attr_reader :resource,:service_executed

    def initialize(resource,options = {})
        @resource = resource
    end

    def call

      Rails.logger.info { "TenantServiceExecutor is called. " }
  
      return if resource.blank?

      tenant_service = TenantService.find_by({user_id: resource.id})
      return if tenant_service.blank? || tenant_service.service_executed?
     
      # Tenant Service object is created only when reseller register and purchase the plan
      # if tenant service object does not exits then do not invoke below services
      # Or if exist but not executed then invoke below service classes
      # check StoreCreator to see how this TenantService object is being created

      TenantManager::UserTenantUpdater.new(tenant_service.user,tenant_service.account_id).call
      TenantManager::StoreTenantUpdater.new(tenant_service.user,tenant_service.account_id).call
    
      tenant_service.update(service_executed: true)
      @service_executed = tenant_service.service_executed

      Rails.logger.info { "TenantServiceExecutor executed successfully. " }

      tenant_service
    end 
  end
end
