Rails.application.routes.draw do
  get "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"
  get "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"
  resources :sessions, only: [:index, :show, :destroy]
  resource :password, only: [:edit, :update]
  namespace :identity do
    resource :email, only: [:edit, :update]
    resource :email_verification, only: [:show, :create]
    resource :password_reset, only: [:new, :edit, :create, :update]
  end
  namespace :authentications do
    resources :events, only: :index
  end
  post "users/:user_id/masquerade", to: "masquerades#create", as: :user_masquerade
  namespace :sessions do
    resource :sudo, only: [:new, :create]
  end
  root "home#show"

  # I don't yet know how to check for authenticated user with authentication-zero
  # authenticate :user, ->(user) { user.is_admin? } do
    mount Avo::Engine, at: Avo.configuration.root_path
  # end
end
