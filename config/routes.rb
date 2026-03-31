Rails.application.routes.draw do
  get 'groups/create'
  devise_for :users
  root "top#index"

  resources :groups, only: [:create] do
    collection do
      post :join
    end
  end
end
