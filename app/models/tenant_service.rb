# frozen_string_literal: true

class TenantService < ApplicationRecord
  belongs_to :user, class_name: 'Spree::User'
  belongs_to :account, class_name: '::Account'
  # belongs_to :store, :class_name=>'Spree::Store'
end
