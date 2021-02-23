class Account < ApplicationRecord
	has_one :spree_store ,:class_name=>'Spree::Store'
end
