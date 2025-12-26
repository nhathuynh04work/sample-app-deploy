Rails.application.routes.draw do
    get "/login", to: "sessions#new"
    post "/login", to: "session#create"
    delete "/logout", to: "session#destroy"

    get "/signup", to: "users#new"

    get "/help", to: "static_pages#help"
    get "/about", to: "static_pages#about"
    get "/contact", to: "static_pages#contact"

    resources :users
    
    root "static_pages#home"
end
