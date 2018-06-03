Rails.application.routes.draw do
  get 'minings/stop'
  resources :minings

  get 'settings', to: 'settings#index'
  patch 'settings', to: 'settings#save'
  get 'settings/shutdown'
  get 'settings/reboot'

  root 'home#index'
end
