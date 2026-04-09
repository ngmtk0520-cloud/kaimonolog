Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  root "top#index"

  resources :groups, only: [:show, :create, :edit, :update, :destroy] do
    resources :items
    resources :categories, only: [:create]
    collection do
      post :join
      patch :leave
    end
  end

  resources :items, only: [:index, :create, :update, :destroy] do
    collection do
      patch :bulk_update
    end
  end

  resources :categories, only: [:index, :create, :edit, :update, :destroy]

  resources :calendars, only: [:index, :show, ]

  resources :purchase_histories, only: [:new, :create, :edit, :update, :destroy]

  resources :total_expenses, only: [:index]

  resource :settings, only: [:show]
end
