Rails.application.routes.draw do
    # auth
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    get "/signup", to: "users#new"

    # static
    get "/help", to: "static_pages#help"
    get "/about", to: "static_pages#about"
    get "/contact", to: "static_pages#contact"

    # users
    resources :users

    # account activation
    resources :account_activations, only: [:edit]

    # password reset
    resources :password_resets, only: [:new, :edit, :create, :update]

    # root
    root "static_pages#home"
end
