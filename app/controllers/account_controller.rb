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

    def reset_isp_config_password
      @response = spree_current_user.isp_config.update_password
      if @response[:success]
        flash.now[:isp_config_info] = "ISP Config Password reset successfully"
        @isp_new_password = @response[:new_password] 
      else
        flash.now[:isp_config_error] = "Something went wrong"
      end
     
    end

    def reset_solid_cp_password
      @response = spree_current_user.solid_cp.change_user_password
      if @response[:success]
        flash.now[:solid_cp_info] = "SolidCP  Password reset successfully"
        @solid_cp_new_password = @response[:new_password]
      else
         flash.now[:solid_cp_error] = "Something went wrong"
      end
    end
    
end
