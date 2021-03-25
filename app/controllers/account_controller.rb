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
      response  = spree_current_user.solid_cp.add_user
      if response[:success] == true
        flash[:success] = response[:message]
      else
        flash[:error] = response[:message]
      end
    end

end
