class AddCountryCodeToSpreeAddresses < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_addresses, :country_code, :string
  end
end
