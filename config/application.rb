require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OpsPi
  class Application < Rails::Application
    

    config.to_prepare do
      # Load application's model / class decorators
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # Load application's view overrides
      Dir.glob(File.join(File.dirname(__FILE__), "../app/overrides/*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.hosts = nil
    config.active_job.queue_adapter = :sidekiq
    config.active_storage.service = :digitalocean
    config.filter_parameters += ['api-key','auth-userid',:passwd]

    
  
    # config.assets.precompile += %w( store/all.js store/all.css admin/all.js admin/all.css)

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")




    # Override Spree Core routes in order to translate products routes
    initializer "delete_spree_core_routes", after: "add_routing_paths" do |app|
      new_spree_auth_route_path = File.expand_path('../../config/spree_auth_routes_override.rb', __FILE__)
      routes_paths = app.routes_reloader.paths

      spree_devise_auth_route_path = routes_paths.select{ |path| path.include?("spree_auth_devise") }.first

      if spree_devise_auth_route_path.present?
        spree_core_route_path_index = routes_paths.index(spree_devise_auth_route_path)

        routes_paths.delete_at(spree_core_route_path_index)
      
        routes_paths.insert(spree_core_route_path_index, new_spree_auth_route_path)
       
      end
    end

  end
end


