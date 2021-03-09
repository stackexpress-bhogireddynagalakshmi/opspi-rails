class AccountController < Spree::StoreController

	before_action :authenticate_spree_user!

	include Spree::CacheHelper
    respond_to :html

    def subscription

   	end

end
