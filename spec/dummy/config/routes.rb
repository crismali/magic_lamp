Rails.application.routes.draw do

  resources :orders

  mount MagicLamp::Engine => "/magic_lamp"
end
