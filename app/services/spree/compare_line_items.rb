module Spree
  class CompareLineItems
    prepend Spree::ServiceModule::Base

    def call(order:, line_item:, options: {}, comparison_hooks: nil)
      comparison_hooks ||= Rails.application.config.spree.line_item_comparison_hooks

      legacy_part = comparison_hooks.all? do |hook|
        order.send(hook, line_item, options)
      end

      success(legacy_part && compare(line_item, options))
    end

    private
    def compare(_line_item, _options)
      return true if _options['domain'].blank?
      return true if _line_item.domain == _options['domain']

      return false
    end
  end
end