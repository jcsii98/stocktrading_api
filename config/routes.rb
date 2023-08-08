Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    registrations: 'users/registrations'
  }

  get '/users_only', to: 'test#users_only'

  get '/admins_only', to: 'test#admins_only'

  mount_devise_token_auth_for 'Admin', at: 'admin_auth', controllers: {
    registrations: 'admins/registrations'
  }
  as :admin do
  end

  namespace :admin do
    resources :users, only: [:index, :update]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
