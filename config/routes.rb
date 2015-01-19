Rails.application.routes.draw do


  get '/home', to: 'users#new', as: :home

  get '/rooms/:name', to: 'rooms#join'

  get 'rooms/new', as: :new_room



  post '/rooms', to: 'rooms#create'

  get '/rooms/:name/users', to: 'rooms#users', as: :room_users

  get '/rooms/:name/info', to: 'rooms#info', as: :room_info

  get '/rooms/:name/leave', to: 'rooms#leave', as: :room_leave

  get '/rooms/:name/games/:id/next', to: 'games#next_record', as: :next_room_game_record

  post '/rooms/:name/games', to: 'games#create', as: :create_room_game

  patch '/rooms/:name/games/:id', to: 'games#update', as: :update_room_game

  get '/rooms/:name/games/:id/show', to: 'games#show', as: :show_room_game

  get '/rooms/:name/games/new', to: 'games#new', as: :new_room_game

  resources :users

  resources :themes

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
