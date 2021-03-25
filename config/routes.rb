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
  
  # Spree::Core::Engine.routes.draw do
  #   namespace :admin do
  #     resources :accounts
  #     end
  #   end


  get 'hosting/:slug', :controller=> 'hosting',:action=> "hosting_page"
  get 'servers/:slug', :controller=> 'hosting',:action=> "servers"

  resources :hosting,:only=>[:index] do 

  end

  resources :account,:only=>[] do
    collection do
       get :subscription
       get :subscription_cancel
       get :create_solidcp_account
    end
  end


end
