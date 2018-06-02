Rails.application.routes.draw do
  get 'settings', to: 'settings#index'
  patch 'settings', to: 'settings#save'

  root 'home#index'
end
