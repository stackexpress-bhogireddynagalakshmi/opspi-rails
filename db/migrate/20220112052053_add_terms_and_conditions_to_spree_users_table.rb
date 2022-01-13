class AddTermsAndConditionsToSpreeUsersTable < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_users, :terms_and_conditions, :boolean, default: false
    # update existing terms
    Spree::User.update({terms_and_conditions: true})
  end
end
