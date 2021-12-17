module Spree
  module VariantDecorator

    def tax_category
      self.reload
      TenantManager::TenantHelper.unscoped_query { super }
    end
  
  end
end


::Spree::Variant.prepend Spree::VariantDecorator if ::Spree::Variant.included_modules.exclude?(Spree::VariantDecorator)
