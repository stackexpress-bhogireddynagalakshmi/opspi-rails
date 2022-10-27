# frozen_string_literal: true

module IspConfig
  module Mail
    class SpamFilter < Base
      attr_accessor :user

      def initialize(user)
        @user = user
        set_base_uri( user.panel_config["mail"] )
      end

      def find(id)
        response = query({
                           endpoint: get_endpoint,
                           method: :GET,
                           body: {
                             primary_id: id
                           }
                         })

        formatted_response(response, 'find')
      end

      def create(params = {}, opts={})
        response = query({
                           endpoint: create_endpoint,
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             params: params.merge(server_params)
                           }
                         })
        if response.code == "ok"
          user.spam_filters.create({ isp_config_spam_filter_id: response["response"] })

          user_domain = opts[:user_domain]
          user_domain.user_spam_filters.create(user_spam_filter_params(params).merge({ remote_spam_filter_id: response["response"] })) if user_domain.present?

        end
        formatted_response(response, 'create')
      end

      def update(id, params = {})
        user_spam_filter = UserSpamFilter.find(id)
        response = query({
                           endpoint: update_endpoint,
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: user_spam_filter.remote_spam_filter_id,
                             params: params.merge(server_params)
                           }
                         })


        if response.code == 'ok'
          user_spam_filter.update(user_spam_filter_params(params))
        end

        formatted_response(response, 'update')
      end

      def destroy(id)
        user_spam_filter = UserSpamFilter.find(id)
        response = query({
                           endpoint: delete_endpoint,
                           method: :DELETE,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: id
                           }
                         })
        if response.code == "ok"
          user.spam_filters.find_by_isp_config_spam_filter_id(user_spam_filter.remote_spam_filter_id).destroy
          user_spam_filter.destroy
        end
        formatted_response(response, 'delete')
      end

      def all(type)
        response = query({
                           endpoint: get_endpoint,
                           method: :GET,
                           body: {
                             primary_id: "-1"
                           }
                         })

        response.response.reject! { |x| list_ids.exclude?(x.wblist_id.to_i) }

        response.response.select! { |x| x.wb == type }

        formatted_response(response, 'list')
      end

      private

      def list_ids
        user.spam_filters.pluck(:isp_config_spam_filter_id)
      end

      def formatted_response(response, action)
        if  response.code == "ok"
          {
            success: true,
            message: I18n.t("isp_config.spam_filters.#{action}"),
            response: response
          }
        else
          {
            success: false,
            message: I18n.t('isp_config.something_went_wrong', message: response.message),
            response: response
          }
        end
      end

      def server_params
        {
          server_id: IspConfig::Config.api_web_server_id(user)
        }
      end

      def user_spam_filter_params(params)
        {
          email: params[:email],
          priority: params[:priority],
          active: params[:active] == 'y',
          wb:   params[:wb]
        }
      end
    end
  end
end
