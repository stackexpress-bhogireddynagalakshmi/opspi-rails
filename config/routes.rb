require 'sidekiq/web'

Rails.application.routes.draw do
  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to
  # Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the
  # :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being
  # the default of "spree".
  mount Spree::Core::Engine, at: '/'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  authenticate :spree_user, lambda { |u| u.superadmin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_scope :spree_user do
    get '/confirmations/new' => 'spree/user_confirmations#new', :as => :new_confirmation
    get '/password/recover' => 'spree/user_passwords#new', :as => :recover_password
  end
  
  Spree::Core::Engine.routes.draw do
  namespace :spree do
    namespace :admin do
    end
  end
    namespace :admin do
      resources :diagnostics, only: [:index]
      resources :my_store do
        collection do 
          post :validate_domain
        end
      end
      resources :panels do
        collection do 
          get :solidcp
        end
      end


      get 'my_account_profiles', :controller=> 'my_account_profiles',:action=>"index"
      get 'my_account_invoices', :controller=> 'my_account_invoices',:action=>"index"
      get 'my_account_orders', :controller=> 'my_account_orders',:action=>"index"
      get 'dashboard', :controller=> 'dashboard',:action=>"index"
      get 'my_account_subscriptions', :controller=> 'my_account_subscriptions',:action=>"index"
      get '/account/subscription_cancel', :controller=> 'account#subscription_cancel'
      

      resources :domain_registrations do 
        collection do
          get :setup_reseller_club
          post :update_reseller_club
        end
      end

      resources :user_domains
      namespace :dns do
        resources :hosted_zones do
          member do
            get :dns
          end
          collection do
            get :zone_overview
          end
          resources :hosted_zone_records          
        end
      end

      namespace :mail do
        resources :domains    
        resources :mail_boxes do
          member do
            get :configurations
            get :reset_password
          end
        end
        resources :mailing_lists  
        resources :spam_filters
        resources :spam_filter_blacklists
        resources :spam_filter_whitelists

        resources :statistics do
          collection do
            get :mailbox_quota
            get :mailbox_traffic
          end
        end
        resources :forwards
      end

      namespace :sites do
        resources :websites
        # resources :backup, only: [:index, :update]
        resources :ftp_users do
          member do
            get :reset_password
             get :configurations
          end
        end
        resources :sub_domains
        resources :protected_folders
        resources :protected_folder_users
        resources :isp_databases do
          member do
            get :reset_password
            get :configurations
          end
        end
      end

      resources :wizards do 
        collection do
          get :reset_password
        end
      end

      namespace :windows do
        resources :domains
      end

      post 'sites/websites/enable_disable_web_domain', :controller=> 'sites/websites', :action=> "enable_disable_web_domain", as: 'enable_disable_web_domain'
      post 'windows/domains/disable_webservice', :controller=> 'windows/domains', :action=> "disable_webservice", as: 'disable_webservice'
      post 'sites/websites/enable_webservice', :controller=> 'sites/websites', :action=> "enable_webservice", as: 'enable_webservice'
      post 'sites/websites/update_isp_ssl', :controller=> 'sites/websites', :action=> "update_isp_ssl", as: 'update_isp_ssl'
      post 'dns/hosted_zones/enable_dns_services', :controller=> 'dns/hosted_zones',:action=>"enable_dns_services", as: 'enable_dns_services'
      post 'dns/hosted_zones/disable_dns_services', :controller=> 'dns/hosted_zones',:action=>"disable_dns_services", as: 'disable_dns_services'
      post 'dns/hosted_zones/get_config_details', :controller=> 'dns/hosted_zones',:action=>"get_config_details", as: 'get_config_details'
      get 'website_builder/site_builders', :controller=> 'website_builder/site_builders',:action=>"index", as: 'site_builder'
      post 'website_builder/site_builders', :controller=> 'website_builder/site_builders',:action=>"create", as: 'site_builder_create'
      post 'windows/domains/get_ssl', :controller=> 'windows/domains', :action=> "get_ssl", as: 'get_ssl'
    end
  end
  
  get 'register-domain', :controller=> 'hosting',:action=> "register_domain"
  post 'search_domain', :controller=> 'hosting',:action=> "search_domain"
  get 'hosting/:slug', :controller=> 'hosting',:action=> "hosting_page"
  get 'servers/:slug', :controller=> 'hosting',:action=> "servers"
  get 'orders/:id/order_pdf', :controller=> 'spree/orders', :action=> 'order_pdf'

  resources :hosting,:only=>[:index] do 

  end

  resources :account,:only=>[] do
    collection do
       get :subscription
       get :subscription_cancel
       get :create_solidcp_account
       get :get_hosting_plan_quotas
       get :reset_isp_config_password
       get :reset_solid_cp_password
       get :pay_invoice
    end
  end

 
end
