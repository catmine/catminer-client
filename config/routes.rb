Rails.application.routes.draw do
  resources :minings
  get 'settings', to: 'settings#index'
  patch 'settings', to: 'settings#save'

  root 'home#index'
end
