Rails.application.routes.draw do

  resources :orders

  mount MagicLamp::Genie, at: "/magic_lamp"
end
