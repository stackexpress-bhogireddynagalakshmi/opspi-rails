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
      solid_cp_plan_id = params[:solid_cp_plan_id]
      @product = Spree::Product.new
    end
    
end
