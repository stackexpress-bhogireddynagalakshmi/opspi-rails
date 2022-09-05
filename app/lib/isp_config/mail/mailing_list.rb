# frozen_string_literal: true

module IspConfig
  module Mail
    class MailingList < Base
      attr_accessor :user

      def initialize(user)
        @user = user
        set_base_uri( user.panel_config["mail"] )
      end

      def find(id)
        response = query({
                           endpoint: '/json.php?mail_mailinglist_get',
                           method: :GET,
                           body: {
                             primary_id: id
                           }
                         })

        formatted_response(response, 'find')
      end

      def create(params = {}, opts={})
        response = query({
                           endpoint: '/json.php?mail_mailinglist_add',
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             params: params.merge(server_params)
                           }
                         })
        if response.code == "ok"
          user.mailing_lists.create({ isp_config_mailing_list_id: response["response"] }) 
          user_domain = opts[:user_domain]
          user_domain.user_mailing_lists.create(mailing_list_params(params).merge({ remote_mailing_list_id: response["response"] })) if user_domain.present?
        end

        formatted_response(response, 'create')
      end

      def update(id, params = {})
        mailing_list = UserMailingList.find(id)
        response = query({
                           endpoint: '/json.php?mail_mailinglist_update',
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: mailing_list.remote_mailing_list_id,
                             params: params.merge(server_params)
                           }
                         })


        if response.code == "ok"
          mailing_list.update(mailing_list_params(params))
        end

        formatted_response(response, 'update')
      end

      def destroy(id)
        mailing_list = UserMailingList.find(id)
        response = query({
                           endpoint: '/json.php?mail_mailinglist_delete',
                           method: :DELETE,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: mailing_list.remote_mailing_list_id
                           }
                         })

        if response.code == "ok"
          user.mailing_lists.find_by_isp_config_mailing_list_id(mailing_list.remote_mailing_list_id).destroy 
          mailing_list.destroy
        end

        formatted_response(response, 'delete')
      end

      def all
        response = query({
                           endpoint: '/json.php?mail_mailinglist_get',
                           method: :GET,
                           body: {
                             primary_id: "-1"
                           }
                         })
        response.response.reject! { |x| maillist_ids.exclude?(x.mailinglist_id.to_i) }

        formatted_response(response, 'list')
      end

      private

      def maillist_ids
        user.mailing_lists.pluck(:isp_config_mailing_list_id)
      end

      def formatted_response(response, action)
        if  response.code == "ok"
          {
            success: true,
            message: I18n.t("isp_config.mailing_lists.#{action}"),
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

      def mailing_list_params(params)

        {
          listname: params[:listname],
          email:    params[:email],
        }

      end
    end
  end
end
