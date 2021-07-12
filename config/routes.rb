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
  
  Spree::Core::Engine.routes.draw do
    namespace :admin do

      resources :panels do
        collection do 
          get :solidcp
        end
      end
    end
  end


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
    end
  end  
end
