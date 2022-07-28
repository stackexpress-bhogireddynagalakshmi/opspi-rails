# frozen_string_literal: true

module IspConfig
  module Mail
    class MailUser < Base
      attr_accessor :user

      def initialize(user)
        @user = user
        set_base_uri( user.panel_config["mail"] )
      end

      def find(id)
        response = query({
                           endpoint: '/json.php?mail_user_get',
                           method: :GET,
                           body: {
                             primary_id: id
                           }
                         })

        formatted_response(response, 'find')
      end

      def create(params = {})
        response = query({
                           endpoint: '/json.php?mail_user_add',
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             params: params.merge(server_params).merge({ login: params[:email] })
                           }
                         })

        user.mail_users.create({ isp_config_mailuser_id: response["response"] }) if response.code == "ok"

        formatted_response(response, 'create')
      end

      def update(primary_id, params = {})
        response = query({
                           endpoint: '/json.php?mail_user_update',
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: primary_id,
                             params: params.merge(server_params).merge({ login: params[:email] }).reject do |_x, v|
                                       v.blank?
                                     end
                           }
                         })

        formatted_response(response, 'update')
      end

      def destroy(primary_id)
        response = query({
                           endpoint: '/json.php?mail_user_delete',
                           method: :DELETE,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: primary_id
                           }
                         })
        user.mail_users.find_by_isp_config_mailuser_id(primary_id).destroy if response.code == "ok"

        formatted_response(response, 'delete')
      end

      def all
        response = query({
                           endpoint: '/json.php?mail_user_get',
                           method: :GET,
                           body: {
                             primary_id: "-1"
                           }
                         })
        response.response.reject! { |x| mail_user_ids.exclude?(x.mailuser_id.to_i) }

        formatted_response(response, 'list')
      end

      private

      def mail_user_ids
        user.mail_users.pluck(:isp_config_mailuser_id)
      end

      def formatted_response(response, action)
        if  response.code == "ok"
          {
            success: true,
            message: I18n.t("isp_config.mail_user.#{action}"),
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
          server_id: ENV['ISP_CONFIG_WEB_SERVER_ID'],
          move_junk: 'n',
          custom_mailfilter: 'spam',
          purge_trash_days: 90,
          purge_junk_days: 90
        }
      end
    end
  end
end
