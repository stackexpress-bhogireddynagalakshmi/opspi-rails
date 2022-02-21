module IspConfig
  class SubDomain < Base
    attr_accessor :user

    def initialize user
      @user = user
    end

    def find(id)
      response = query({
        :endpoint => '/json.php?sites_web_subdomain_get',
        :method => :GET,
        :body => { 
          primary_id: id
        }}
      )

      formatted_response(response,'find')
    end

    def create(params={})
      response = query({
        :endpoint => '/json.php?sites_web_subdomain_add',
        :method => :POST,
        :body => { 
          client_id: user.isp_config_id,
          params: params.merge(server_params)
        }}
      )

      user.sub_domains.create({isp_config_sub_domain_id: response["response"]}) if response.code == "ok"
      
      formatted_response(response,'create')
    end

    def update(primary_id,params={})
      response = query({
        :endpoint => '/json.php?sites_web_subdomain_update',
        :method => :POST,
        :body => { 
          client_id: user.isp_config_id,
          primary_id: primary_id,
          params: params.merge(server_params)
        }}
      )

      formatted_response(response,'update')      
    end

    def destroy(primary_id)
      response = query({
        :endpoint => '/json.php?sites_web_subdomain_delete',
        :method => :DELETE,
        :body => { 
          client_id: user.isp_config_id,
          primary_id: primary_id
        }}
      )

      user.sub_domains.find_by_isp_config_sub_domain_id(primary_id).destroy if response.code == "ok"
      formatted_response(response,'delete')
    end

    def all
      response = query({
        :endpoint => '/json.php?sites_web_subdomain_get',
        :method => :GET,
        :body => { 
          primary_id: "-1"
        }}
      )

      response.response.reject!{|x| website_ids.exclude?(x.domain_id.to_i)} if response.response

      formatted_response(response,'list')
    end

    private

    def website_ids
      user.sub_domains.pluck(:isp_config_sub_domain_id)
    end

    def formatted_response(response,action)
      if  response.code == "ok"
        {
          :success=>true,
          :message=>I18n.t("isp_config.website.#{action}"),
          response: response
        }
      else
        { 
          :success=>false,
          :message=> I18n.t('isp_config.something_went_wrong',message: response.message),
          response: response
        }
      end
    end

    def server_params
      {server_id: ENV['ISP_CONFIG_WEB_SERVER_ID']}
    end
  end
end
