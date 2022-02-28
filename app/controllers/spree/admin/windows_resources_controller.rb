# frozen_string_literal: true

module Spree
  module Admin
    # Resource Base Class
    class WindowsResourcesController < Spree::Admin::BaseController
      before_action :set_resource, only: %i[edit update destroy]

      def index; end

      def new; end

      def edit; end

      def create
        @response = windows_api.create(resource_params)
        @proxy_resource = convert_to_mash(resource_params.to_h)

        yield if block_given?

        set_flash
        if @response[:success]
          redirect_to resource_index_path
        else
          render :new
        end
      end

      def update
        @response = windows_api.update(resource_id, resource_params)
        @proxy_resource = convert_to_mash(resource_params.to_h)

        yield if block_given?

        set_flash
        if @response[:success]
          redirect_to resource_index_path
        else
          render :edit
        end
      end

      def destroy
        @response = windows_api.destroy(resource_id)

        yield if block_given?

        set_flash
        redirect_to resource_index_path
      end

      private

      def set_flash
        if @response[:success]
          flash[:success] = @response[:message]
        else
          flash[:error] = @response[:message]
        end
      end


      def set_resource
        response = windows_api.find(resource_id)
        #TODO: check if resource package id belongs to current user
        if response.success?
          @api_resource = convert_to_mash(response.body[get_response_key.to_sym][get_result_key.to_sym])
        end
        
        redirect_to resource_index_path, notice: 'Not Authorized' if @api_resource.blank?
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
