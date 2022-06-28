module Spree
    module AddressesHelper
      def address_field(form, method, address_id = 'b', &handler)
        content_tag :div, id: [address_id, method].join, class: 'form-group checkout-content-inner-field has-float-label' do
          if handler
            yield
          else
            is_required = Spree::Address.required_fields.include?(method)
            method_name = I18n.t("activerecord.attributes.spree/address.#{method}")
            required = Spree.t(:required)
            form.label(method_name,
                        is_required ? "#{method_name} #{required}" : method_name,
                        class: 'text-uppercase form-label')+
            form.text_field(method,
                            class: ['form-control'].compact,
                            required: is_required,
                            placeholder: is_required ? "#{method_name} #{required}" : method_name,
                            aria: { label: method_name }) 
          end
        end
      end
  
      def address_zipcode(form, country, address_id = 'b')
        country ||= address_default_country
        is_required = country.zipcode_required?
        method_name = Spree.t(:zipcode)
        required = Spree.t(:required)
        form.label(:zipcode,
        is_required ? "#{method_name} #{required}" : method_name,
        class: 'text-uppercase form-label',
        id: address_id + '_zipcode_label') +
        form.text_field(:zipcode,
                        class: ['form-control'].compact,
                        required: is_required,
                        placeholder: is_required ? "#{method_name} #{required}" : method_name,
                        aria: { label: Spree.t(:zipcode) })
      end
  
      def address_state(form, country, address_id = 'b')
        country ||= address_default_country
        have_states = country.states.any?
        state_elements = [
          form.label(Spree.t(:state).downcase,
                       raw(Spree.t(:state) + content_tag(:abbr, " #{Spree.t(:required)}")),
                       class: [have_states ? 'form-label' : nil, ' text-uppercase'].compact,
                       id: address_id + '_state_label') +
          form.collection_select(:state_id, checkout_zone_applicable_states_for(country).sort_by(&:name),
                                :id, :name,
                                 { prompt: Spree.t(:state) },
                                 class: ['form-select form-control'].compact,
                                 aria: { label: Spree.t(:state) },
                                 disabled: !have_states) 
            # form.text_field(:state_name,
            #                 class: ['form-control mt-2'].compact,
            #                 aria: { label: Spree.t(:state) },
            #                 disabled: have_states,
            #                 placeholder: Spree.t(:state) + " #{Spree.t(:required)}")
            
            # image_tag('arrow.svg',
            #           class: [!have_states ? 'hidden' : nil, 'position-absolute spree-flat-select-arrow'].compact)
        ].join.tr('"', "'").delete("\n")
  
        content_tag :span, class: 'd-block position-relative' do
          state_elements.html_safe
        end
      end
  
      def user_available_addresses
        @user_available_addresses ||= begin
          return [] unless try_spree_current_user
  
          states = current_store.countries_available_for_checkout.each_with_object([]) do |country, memo|
            memo << current_store.states_available_for_checkout(country)
          end.flatten
  
          try_spree_current_user.addresses.
            where(country_id: states.pluck(:country_id).uniq)
        end
      end
  
      def checkout_zone_applicable_states_for(country)
        current_store.states_available_for_checkout(country)
      end
  
      def address_default_country
        @address_default_country ||= current_store.default_country
      end
    end
  end