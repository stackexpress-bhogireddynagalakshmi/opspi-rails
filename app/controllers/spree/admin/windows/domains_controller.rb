# frozen_string_literal: true
module Spree
  module Admin
    module Windows
      # Domain controller
      class DomainsController < Spree::Admin::WindowsResourcesController

        def index
          response = windows_api.all || []
          @resources = convert_to_mash(response.body[:get_domains_response][:get_domains_result][:domain_info]) rescue []
        end
       
        def create
          response = windows_api.add_domain(resource_params)

          if response[:success] == true
            @proxy_resource = convert_to_mash(resource_params.to_h)
            resource_index_path
          else
            render :new
          end
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
          params.require("web_domain").permit(:domain_name,:is_sub_domain, :hosting_allowed, :is_preview_domian, :is_domain_pointer, :enable_dns)
        end

        def resource_index_path
          admin_windows_domains_path
        end

        def windows_api
          current_spree_user.solid_cp.web_domain
        end

      end
    end
  end
end
