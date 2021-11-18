Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'users/login', to: 'users#login'
      put 'users/reset_password', to: 'users#reset_password'
      post 'sign_up', to: 'users#create', as: :sign_up

    end
  end
  # devise_for :users, controllers: {
  #   sessions: 'users/sessions'
  # }
end