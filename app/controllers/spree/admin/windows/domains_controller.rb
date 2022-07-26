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
          if params[:website][:id].to_i == 0
            pointer = current_spree_user.solid_cp.website.get_web_site_pointers(params)
            current_spree_user.solid_cp.website.delete_web_site_pointer({web_site_id: pointer[:web_site_id], website:{ web_domain_id: pointer[:domain_id] }}) unless pointer.blank?
          
            ensure_a_record(params)
            
            @response = current_spree_user.solid_cp.website.le_install_certificate(params)
          else
            @response = current_spree_user.solid_cp.website.delete_certificate(params)
          end
          set_flash
          redirect_to request.referrer
        end

        def ensure_a_record(params)
          dns_records = current_spree_user.isp_config.hosted_zone.get_all_hosted_zone_records(params[:website][:dns_id])[:response].response
          a_records = dns_records.select{|x| x[:id] if x[:type] == 'A' && x[:data] == ENV['SOLID_CP_WEB_SERVER_IP']}

          create_a_record(params) if a_records.blank?
        end

        def create_a_record(a_rec_params)
          
          a_record_params={
            type: "A",
            name: a_rec_params[:website][:domain],
            hosted_zone_name: nil,
            ipv4: ENV['SOLID_CP_WEB_SERVER_IP'],
            ttl: "3600",
            hosted_zone_id: a_rec_params[:website][:dns_id],
            client_id: user.isp_config_id
          }
          current_spree_user.isp_config.hosted_zone_record.create(a_record_params)
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
