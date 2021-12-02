class AddDomainRegistrationColumnToLineItems < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_line_items,:domain_successfully_registered,:boolean,:default => false,null: false
    add_column :spree_line_items,:domain_registered_at,:datetime
    add_column :spree_line_items,:api_response,:text
  end
end
