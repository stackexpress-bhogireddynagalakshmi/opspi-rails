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

      def create(params = {}, opts={})
        params = sanitize(params)
        response = query({
                           endpoint: '/json.php?mail_user_add',
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             params: params.merge(server_params).merge({ login: params[:email] })
                           }
                         })


        if response.code == "ok"
          user.mail_users.create({ isp_config_mailuser_id: response["response"] }) #TODO: Legacy table to be removed
          user_domain = opts[:user_domain]
          user_domain.user_mailboxes.create(mailbox_params(params).merge({ remote_mailbox_id: response["response"] })) if user_domain.present?
        end


        formatted_response(response, 'create')
      end

      def update(id, params = {})
        params = sanitize(params)
        mailbox = UserMailbox.find(id)

        response = query({
                           endpoint: '/json.php?mail_user_update',
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: mailbox.remote_mailbox_id,
                             params: params.merge(server_params).merge({ login: params[:email] }).reject do |_x, v|
                                       v.blank?
                                     end
                           }
                         })

        if response.code == "ok"
          mailbox.update(mailbox_params(params))
        end

        formatted_response(response, 'update')
      end

      def destroy(id)
        mailbox = UserMailbox.find(id)
        response = query({
                           endpoint: '/json.php?mail_user_delete',
                           method: :DELETE,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: mailbox.remote_mailbox_id
                           }
                         })
        if response.code == "ok"
          user.mail_users.find_by_isp_config_mailuser_id(mailbox.remote_mailbox_id).destroy 
          mailbox.destroy
        end

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
          server_id: IspConfig::Config.api_web_server_id(user),
          move_junk: 'n',
          custom_mailfilter: 'spam',
          purge_trash_days: 90,
          purge_junk_days: 90
        }
      end


      def sanitize(params)
        return params if  params[:email].blank?
        params[:email] = params[:email][0..-2]  if  params[:email][-1] == '.'

        return params
      end

      def mailbox_params(params)
        {
          name:              params[:name],
          email:             params[:email],
          quota:             params[:quota],
          cc:                params[:cc],
          forward_in_lda:    params[:forward_in_lda],
          policy:            params[:policy],
          postfix:           boolean(params[:postfix]),
          disablesmtp:       boolean(params[:disablesmtp]),
          disabledeliver:    boolean(params[:disabledeliver]),
          greylisting:       boolean(params[:greylisting]),
          disableimap:       boolean(params[:disableimap]),
          disablepop3:       boolean(params[:disablepop3])
        }.reject{|k, v| v.blank?}
      end

      def boolean(val)
        val == 'y' ? true : false
      end
    end
  end
end
