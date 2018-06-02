Rails.application.routes.draw do
  resources :minings

  get 'minings/stop'

  get 'settings', to: 'settings#index'
  patch 'settings', to: 'settings#save'
  get 'settings/shutdown'
  get 'settings/reboot'

  root 'home#index'
end
