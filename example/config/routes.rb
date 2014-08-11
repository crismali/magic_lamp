Rails.application.routes.draw do
  resources :things
  mount MagicLamp::Genie, at: "/magic_lamp" if defined?(MagicLamp)
end
