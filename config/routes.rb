Rails.application.routes.draw do
  get "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"
  get "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"
  get "/auth/failure", to: "sessions/omniauth#failure"
  get "/auth/:provider/callback", to: "sessions/omniauth#create"
  post "/auth/:provider/callback", to: "sessions/omniauth#create"

  namespace :authentications do
    resources :events, only: :index
  end
  resource :dashboard, only: [:show]
  namespace :identity do
    resource :email, only: [:edit, :update]
    resource :email_verification, only: [:show, :create]
    resource :password_reset, only: [:new, :edit, :create, :update]
  end
  resource :password, only: [:edit, :update]
  resources :sessions, only: [:index, :show, :destroy]
  namespace :sessions do
    resource :sudo, only: [:new, :create]
  end

  resources :mentor_questionnaires, only: [:new, :create, :edit, :update]
  resources :applicant_questionnaires, only: [:new, :create, :edit, :update]
  resources :mentors, only: [:index]
  resources :applicants, only: [:index]
  resources :mentorships, only: [:index]
  resources :matching, only: [:index, :show, :create]

  post "users/:user_id/masquerade", to: "masquerades#create", as: :user_masquerade

  root "home#show"
end
