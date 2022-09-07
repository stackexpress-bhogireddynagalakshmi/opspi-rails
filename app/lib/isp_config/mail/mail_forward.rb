# frozen_string_literal: true

module IspConfig
  module Mail
    class MailForward < Base
      attr_accessor :user

      def initialize(user)
        @user = user
        set_base_uri( user.panel_config["mail"] )
      end

      def find(id)
        response = query({
                           endpoint: '/json.php?mail_forward_get',
                           method: :GET,
                           body: {
                             primary_id: id
                           }
                         })

        formatted_response(response, 'find')
      end

      def create(params = {}, opts={})
        response = query({
                           endpoint: '/json.php?mail_forward_add',
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             params: params.merge(server_params)
                           }
                         })

        if response.code == "ok"
          user.mail_forwards.create({ isp_config_mail_forward_id: response["response"] })
          user_domain = opts[:user_domain]
          user_domain.user_mail_forwards.create(mail_forward_params(params).merge({ remote_mail_forward_id: response["response"] })) if user_domain.present?

        end

        formatted_response(response, 'create')
      end

      def update(id, params = {})
        mail_forward = UserMailForward.find(id)
        response = query({
                           endpoint: '/json.php?mail_forward_update',
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: mail_forward.remote_mail_forward_id,
                             params: params.merge(server_params)
                           }
                         })


        if response.code == "ok"
          mail_forward.update(mail_forward_params(params))
        end

        formatted_response(response, 'update')
      end

      def destroy(id)
        mail_forward = UserMailForward.find(id)
        response = query({
                           endpoint: '/json.php?mail_forward_delete',
                           method: :DELETE,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: mail_forward.remote_mail_forward_id
                           }
                         })

        if response.code == "ok"
          user.mail_forwards.find_by_isp_config_mail_forward_id( mail_forward.remote_mail_forward_id).destroy
          mail_forward.destroy
        end
        formatted_response(response, 'delete')
      end

      def all
        response = query({
                           endpoint: '/json.php?mail_forward_get',
                           method: :GET,
                           body: {
                             primary_id: "-1"
                           }
                         })
        response.response.reject! { |x| mail_forward_ids.exclude?(x.forwarding_id.to_i) }

        formatted_response(response, 'list')
      end

      private

      def mail_forward_ids
        user.mail_forwards.pluck(:isp_config_mail_forward_id)
      end

      def formatted_response(response, action)
        if  response.code == "ok"
          {
            success: true,
            message: I18n.t("isp_config.mail_forward.#{action}"),
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

      def mail_forward_params(params)
        {
          source: params[:source],
          destination: params[:destination],
          active: params[:active] == 'y' ? true : false,
          allow_send_as: params[:allow_send_as] == 'y' ? true : false,
          greylisting: params[:greylisting] == 'y' ? true : false
        }

      end
    end
  end
end
