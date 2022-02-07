module IspConfig
 module Mail
   class SpamFilter < Base
    attr_accessor :user

    def initialize user
      @user = user
    end

    def find(id)
      response = query({
        :endpoint => get_endpoint,
        :method => :GET,
        :body => { 
          primary_id: id
        }}
      )

      formatted_response(response,'find')
    end

    def create(params={})
      response = query({
        :endpoint => create_endpoint,
        :method => :POST,
        :body => { 
          client_id: user.isp_config_id,
          params: params.merge(server_params)
        }}
      )
      user.spam_filters.create({isp_config_spam_filter_id: response["response"]}) if response.code == "ok"
      formatted_response(response,'create')
    end

    def update(primary_id,params={})
      response = query({
        :endpoint => update_endpoint,
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
        :endpoint => delete_endpoint,
        :method => :DELETE,
        :body => { 
          client_id: user.isp_config_id,
          primary_id: primary_id
        }}
      )
      user.spam_filters.find_by_isp_config_spam_filter_id(primary_id).destroy if response.code == "ok"
      formatted_response(response,'delete')
    end

    def all(type)
      response = query({
        :endpoint => get_endpoint,
        :method => :GET,
        :body => { 
          primary_id: "-1"
        }}
      )

      response.response.reject!{ |x| list_ids.exclude?(x.wblist_id.to_i) }

      response.response.reject!{ |x| x.wb != type }

      formatted_response(response,'list')
    end

    private

    def list_ids
      user.spam_filters.pluck(:isp_config_spam_filter_id)
    end

    def formatted_response(response,action)
      if  response.code == "ok"
        {
          :success=>true,
          :message=>I18n.t("isp_config.spam_filters.#{action}"),
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
      {
        server_id: ENV['ISP_CONFIG_WEB_SERVER_ID']
      }
    end
  end
 end
end