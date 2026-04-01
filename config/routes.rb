Rails.application.routes.draw do
  devise_for :users
  root "top#index"

  resources :groups, only: [:create] do
    collection do
      post :join
    end
  end

  resources :items, only: [:index, :create, :update, :destroy]
end
