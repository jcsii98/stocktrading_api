Rails.application.routes.draw do

  mount_devise_token_auth_for 'User', at: 'auth'

  get '/users_only', to: 'test#users_only'

  get '/admins_only', to: 'test#admins_only'

  get '/approved_users_only', to: 'test#approved_users_only'
  
  mount_devise_token_auth_for 'Admin', at: 'admin_auth'

  resource :user, only: [:update, :show]

  resource :admin, only: [:show]
  
  namespace :admin do
    resources :users, only: [:index, :show]
    resources :pending_users, only: [:index, :show, :update]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get '/stocks', to: 'stocks#index'
  patch '/stocks', to: 'stocks#update'
  # test api call route
  resources :stocks do
    collection do
      get :test_rest
      get :test_party
    end
  end
  post '/update_stocks', to: 'stocks#update_stocks'

  get '/portfolios', to: 'portfolios#index'
  
  post '/portfolios', to: 'portfolios#create'

  patch '/portfolios/:id', to: 'portfolios#update'

  delete 'portfolios/:id', to: 'portfolios#destroy'

  resources :portfolios do
    collection do
      get :index_by_stock_symbol
      get :index_by_user
    end
    resources :transactions, except: [:delete] do
    end
  end

end
