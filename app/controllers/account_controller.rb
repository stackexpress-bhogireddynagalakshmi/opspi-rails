class AccountController < Spree::StoreController

	before_action :authenticate_spree_user!

	include Spree::CacheHelper
    respond_to :html

    def subscription

   	end

   	def subscription_cancel
   		@subscription = Subscription.find(params[:subscription_id])
   		@subscription.status = false
   		@subscription.canceled_at = Time.zone.now
   		if @subscription.save
   			flash[:success] = Spree.t('subscription_canceled')
   		else
   			flash[:error] = Spree.t('some_thing_went_wrong')
   		end
   		render "subscription"
   	end


    def create_solidcp_account
      ProvisioningJob.perform_later(spree_current_user.id)
    end

    def get_hosting_plan_quotas
      solid_cp_plan_id = current_store.solid_cp_master_plan_id || 10
      response = SolidCp::Plan.get_hosting_plan_quotas(solid_cp_plan_id)
      groups  = response.body[:get_hosting_plan_quotas_response][:get_hosting_plan_quotas_result][:diffgram][:new_data_set][:table]  
      groups = groups.select{|x| x[:enabled]}
      quotas  = response.body[:get_hosting_plan_quotas_response][:get_hosting_plan_quotas_result][:diffgram][:new_data_set][:table1]     
      render :partial=> 'spree/admin/products/solid_cp_quota_groups',:locals=>{quota_groups: groups,quotas: quotas},:layout=>false
    end
    
end
