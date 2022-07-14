# frozen_string_literal: true

module Spree
  module Admin
    # Mail Domain controller
    class IspConfigResourcesController < Spree::Admin::BaseController
      before_action :ensure_hosting_panel_access
      before_action :set_resource, only: %i[edit update destroy]

      def index
        response = isp_config_api.all || []
        @resources = if response[:success]
                       response[:response].response
                     else
                       []
                     end
        get_phpadmin_client_url
      end

      def new; end

      def edit
        @response = isp_config_api.find(resource_id)
        @api_resource = @response[:response].response if @response[:success].present?
      end

      def create
        @response = isp_config_api.create(resource_params)
        @proxy_resource = convert_to_mash(resource_params.to_h)

        yield if block_given?

        set_flash
        if @response[:success]
          resource_index_path
        else
          render :new
        end
      end

      def update
        @response = isp_config_api.update(resource_id, resource_params)
        @proxy_resource = convert_to_mash(resource_params.to_h)

        yield if block_given?

        set_flash
        if @response[:success]
          resource_index_path
        else
          render :edit
        end
      end

      def destroy
        @response = isp_config_api.destroy(resource_id)

        yield if block_given?

        set_flash
        resource_index_path
      end

      private

      def get_zone_list
          response = current_spree_user.isp_config.hosted_zone.all_zones || []
          @hosted_zones  = response[:success] ? response[:response].response : []
      end

      def set_flash
        if @response[:success]
          flash[:success] = @response[:message]
        else
          flash[:error] = @response[:message]
        end
      end

      def spam_filter_params
        params.require(resource_name).permit(:email, :priority, :active)
              .merge(filter_type_params)
      end

      def set_resource
        @resource = current_spree_user.send(assoc).send("find_by_#{resource_id_field}", params[:id])

        redirect_to resource_index_path, notice: 'Not Authorized' if @resource.blank?
      end

      def resource_id
        @resource.send(resource_id_field)
      end

      def get_phpadmin_client_url
        ul= IspConfig::Config.user_url
        @phpmyAdminUrl= "#{ul}phpmyadmin/"
      end

      def convert_to_mash(data)
        case data
        when Hash
          Hashie::Mash.new(data)
        when Array
          data.map { |d| Hashie::Mash.new(d) }
        else
          data
        end
      end

    end
  end
end
