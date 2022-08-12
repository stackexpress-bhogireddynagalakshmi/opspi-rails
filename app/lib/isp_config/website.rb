# frozen_string_literal: true

module IspConfig
  class Website < Base
    attr_accessor :user

    def initialize(user)
      @user = user
      set_base_uri( user.panel_config["web_linux"] )
    end

    def find(id)
      response = query({
                         endpoint: '/json.php?sites_web_domain_get',
                         method: :GET,
                         body: {
                           primary_id: id
                         }
                       })

      formatted_response(response, 'find')
    end

    def create(params = {})
      params = sanitze(params)

      response = query({
                         endpoint: '/json.php?sites_web_domain_add',
                         method: :POST,
                         body: {
                           client_id: user.isp_config_id,
                           params: params.merge(server_params)
                         }
                       })
      if response.code == "ok"
        create_a_record(params)
        user.websites.create({ isp_config_website_id: response["response"] })
        user_domain = user.user_domains.where(domain: params[:domain], web_hosting_type: nil).last

        user_domain.update(web_hosting_type: 1)
        user.user_websites.create({user_domain_id: user_domain.try(:id), panel_id: user.panel_config["web_linux"], website_id: response["response"]})
      end
      formatted_response(response, 'create')
    end

    def update(primary_id, params = {})
      params = sanitze(params)
      response = query({
                         endpoint: '/json.php?sites_web_domain_update',
                         method: :POST,
                         body: {
                           client_id: user.isp_config_id,
                           primary_id: primary_id,
                           params: params.merge(server_params)
                         }
                       })

      formatted_response(response, 'update')
    end

    def destroy(primary_id)
      response = query({
                         endpoint: '/json.php?sites_web_domain_delete',
                         method: :DELETE,
                         body: {
                           client_id: user.isp_config_id,
                           primary_id: primary_id
                         }
                       })

      user.websites.find_by_isp_config_website_id(primary_id).destroy if response.code == "ok"
      formatted_response(response, 'delete')
    end

    def all
      response = query({
                         endpoint: '/json.php?sites_web_domain_get',
                         method: :GET,
                         body: {
                           primary_id: "-1"
                         }
                       })

      response.response&.reject! { |x| website_ids.exclude?(x.domain_id.to_i) }

      formatted_response(response, 'list')
    end

    private

    def website_ids
      user.websites.pluck(:isp_config_website_id)
    end

    def formatted_response(response, action)
      if  response.code == "ok"
        {
          success: true,
          message: I18n.t("isp_config.website.#{action}"),
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

    def create_a_record(params)
      dns_id = HostedZone.where(name: params[:domain]).pluck(:isp_config_host_zone_id).first
        a_record_params={
          type: "A",
          name: params[:domain],
          hosted_zone_name: params[:domain],
          ipv4: IspConfig::Config.api_web_server_ip(user),
          ttl: "3600",
          hosted_zone_id: dns_id,
          client_id: user.isp_config_id
        }
        user.isp_config.hosted_zone_record.create(a_record_params)
    end

    def sanitze(params)
      return params if  params[:domain].blank?
      params[:domain] = params[:domain][0..-2]  if  params[:domain][-1] == '.'

      return params
    end

    def server_params
      {
        server_id: ENV['ISP_CONFIG_WEB_SERVER_ID'],
        ip_address: '*',
        type: 'vhost',
        parent_domain_id: 0,
        vhost_type: 'name',
        hd_quota: -1,
        traffic_quota: -1,
        cgi: 'y',
        ssi: 'y',
        suexec: 'y',
        errordocs: 1,
        is_subdomainwww: 1,
        subdomain: 'www',
        php: 'fast-cgi',
        ruby: 'n',
        # redirect_type: '',
        # redirect_path: '',
        ssl: 'y',
        # ssl_state: '',
        # ssl_locality: '',
        # ssl_organisation: '',
        # ssl_organisation_unit: '',
        # ssl_country: '',
        # ssl_domain: '',
        # ssl_request: '',
        # ssl_key: '',
        # ssl_cert: '',
        # ssl_bundle: '',
        # ssl_action: '',
        # stats_password: '',
        stats_type: 'webalizer',
        allow_override: 'All',
        # apache_directives: '',
        php_open_basedir: '/',
        pm: 'ondemand',
        pm_max_requests: 0,
        pm_process_idle_timeout: 10,
        # custom_php_ini: '',
        # backup_interval: '',
        backup_copies: 1,
        backup_format_web: 'default',
        backup_format_db: 'gzip',
        # active: 'y',
        traffic_quota_lock: 'n',
        http_port: '80',
        https_port: '443'
      }
    end
  end
end
