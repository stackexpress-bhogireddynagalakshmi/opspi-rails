# frozen_string_literal: true

module Spree
  module Admin
    module Windows
      # Domain controller
      class DomainsController < Spree::Admin::WindowsResourcesController
        def index
          @response = windows_api.all || []
          @resources = begin
            convert_to_mash(@response.body[:get_domains_response][:get_domains_result][:domain_info])
          rescue StandardError
            []
          end
        end

        def create
          @validation = validate_domain_name(resource_params[:domain_name])
          @proxy_resource = convert_to_mash(resource_params.to_h)

          if @validation[0]
            @response = windows_api.create(resource_params)
            if @response[:success] == true
              set_flash
              redirect_to resource_index_path
            else
              render :new
            end
          else
            render :new
          end
        end

        def update
          response = current_spree_user.solid_cp.virtual_directory
                                       .update(params[:website_id], resource_params.merge({ site_id: params[:website_id] }))
        end

        def destroy
          @response = current_spree_user.solid_cp.website.destroy(params)
          set_flash
          redirect_to request.referrer
        end

        def get_ssl
          @response = current_spree_user.solid_cp.website.install_certificate(params)
          set_flash
          redirect_to request.referrer
        end

        private

        def resource_id
          params[:id]
        end

        def get_response_key
          "get_domain_response"
        end

        def get_result_key
          "get_domain_result"
        end

        def resource_params
          params.require("web_domain").permit(:enable_parent_paths, :enable_directory_browsing,
                                              :enable_dynamic_compression, :enable_static_compression)
        end

        def resource_index_path
          admin_windows_domains_path
        end

        def windows_api
          current_spree_user.solid_cp.web_domain
        end

        def validate_domain_name(domain_name)
          # /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}$/
          matchers = CustomValidator.validate(domain_name, DOMAIN_REGEX)
          return [false, 'Not a valid domain'] unless matchers[0]

          [true]
        end
      end
    end
  end
end
