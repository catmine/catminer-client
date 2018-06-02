Rails.application.routes.draw do
  get 'settings', to: 'settings#index'
  post 'settings', to: 'settings#save'

  root 'home#index'
end
