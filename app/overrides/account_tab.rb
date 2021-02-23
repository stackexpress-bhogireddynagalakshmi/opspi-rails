# Deface::Override.new(
#   :name => "account_tab",
#   :virtual_path => "spree/layouts/admin",
#   :insert_bottom => "[data-hook='admin_tabs'], #admin_tabs[data-hook]",
#   :text => '<%= tab :accounts %>',
#   :url => spree.admin_accounts_path
# )