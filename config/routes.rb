Rails.application.routes.draw do
  devise_for :users
  root "top#index"

  resources :groups, only: [:create] do
    collection do
      post :join
    end
  end

  resources :items, only: [:index, :create, :update, :destroy] do
    collection do
      patch :bulk_update
    end
  end

  resources :categories, only: [:index, :create, :update, :destroy]

  resources :calendars, only: [:index, :show, ]

  resources :purchase_histories, only: [:new, :create, :edit, :update, :destroy]
end
