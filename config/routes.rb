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
  end
  
  Spree::Core::Engine.routes.draw do
    namespace :admin do
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
      
      resources :domain_registrations do 
        collection do
          get :setup_reseller_club
          post :setup_reseller_club
        end
      end

      resources :hosted_zones do
        member do
          get :dns
        end
        resources :hosted_zone_records          
      end

      namespace :mail do
        resources :domains    
        resources :mail_boxes  
        resources :mailing_lists  
        resources :spam_filter_blacklists
        resources :spam_filter_whitelists
      end

      namespace :sites do
        resources :websites
      end
      
    end
  end
  get 'register-domain', :controller=> 'hosting',:action=> "register_domain"
  post 'search_domain', :controller=> 'hosting',:action=> "search_domain"
  get 'hosting/:slug', :controller=> 'hosting',:action=> "hosting_page"
  get 'servers/:slug', :controller=> 'hosting',:action=> "servers"

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
