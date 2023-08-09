Rails.application.routes.draw do

  mount_devise_token_auth_for 'User', at: 'auth'

  get '/users_only', to: 'test#users_only'

  get '/admins_only', to: 'test#admins_only'

  get '/approved_users_only', to: 'test#approved_users_only'
  
  mount_devise_token_auth_for 'Admin', at: 'admin_auth'


  namespace :admin do
    resources :users, only: [:index, :update] do
      collection do
        get :pending_accounts
      end
      member do
        get :show_pending_account
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get '/stocks/available_stocks', to: 'stocks#available_stocks'
end
