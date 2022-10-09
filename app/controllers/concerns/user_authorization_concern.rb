module UserAuthorizationConcern
  extend ActiveSupport::Concern

   def ensure_user_authorization!
      @user = Spree::User.find(primary_key)
      return nil if current_spree_user.superadmin?
      return nil if current_spree_user.store_admin? && @user.account_id == current_spree_user.account_id
      
      flash[:error] = 'Not Found'
      redirect_to admin_users_path and return
  end
end
