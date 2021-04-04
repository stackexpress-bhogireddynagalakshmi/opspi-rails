class Package < ApplicationRecord
	belongs_to :user,:class_name=>'Spree::User',:foreign_key=>'user_id'
end
