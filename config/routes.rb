Rails.application.routes.draw do
  get 'groups/create'
  devise_for :users
  root "top#index"
end
