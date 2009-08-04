# DJS ADDED
module Desert
  module Rails
    module RouteSet
      # Loads the set of routes from within a plugin and evaluates them at this
      # point within an application's main <tt>routes.rb</tt> file.
      #
      # Plugin routes are loaded from <tt><plugin_root>/routes.rb</tt>.
      def routes_from_plugin(name)
        #name = name.to_s
        #routes_path = File.join(
        #  Desert::Manager.plugin_path(name),
        #  "config/desert_routes.rb"
        #)
        routes_path = "config/desert_routes.rb"
        RAILS_DEFAULT_LOGGER.debug "Loading routes from #{routes_path}."
        eval(IO.read(routes_path), binding, routes_path) if File.file?(routes_path)
      end
    end
  end
end
# end DJS

class ActionController::Routing::RouteSet::Mapper
  include Desert::Rails::RouteSet
end

ActionController::Routing::Routes.draw do |map|

  map.routes_from_plugin :community_engine # CE-ORIG
  # added by DJS
  #routes_path = "config/desert_routes.rb"
  #RAILS_DEFAULT_LOGGER.debug "Loading routes from #{routes_path}."
  #eval(IO.read(routes_path), binding, routes_path) if File.file?(routes_path)
  # end DJS
   
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
