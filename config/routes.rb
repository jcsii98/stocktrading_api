Rails.application.routes.draw do

  mount_devise_token_auth_for 'User', at: 'auth'

  get '/users_only', to: 'test#users_only'

  get '/admins_only', to: 'test#admins_only'

  get '/approved_users_only', to: 'test#approved_users_only'
  
  mount_devise_token_auth_for 'Admin', at: 'admin_auth'


  namespace :admin do
    resources :users, only: [:index, :update, :show] do
      collection do
        get :pending_accounts
      end
      get 'pending_accounts/:id', action: 'show_pending_account', on: :collection, as: :show_pending_account
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get '/portfolios/by_user/:user_id', to: 'portfolios#index_by_user'
  get '/portfolios', to: 'portfolios#index'
  get 'portfolios/by_stock/:stock_id', to: 'portfolios#index_by_stock'
  
  post '/portfolios', to: 'portfolios#create'

  delete 'portfolios/:id', to: 'portfolios#destroy'

  resources :portfolios do
    resources :transactions, only: [:index, :create, :show] do
      member do
        patch 'approve_transaction'
      end
    end
  end

  get '/stocks/available_stocks', to: 'stocks#available_stocks'

  get '/stocks/:id/stock_details', to: 'stocks#stock_details'
end
