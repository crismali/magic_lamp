Rails.application.routes.draw do

  resources :orders

  mount MagicLamp::Genie => "/magic_lamp"
end
