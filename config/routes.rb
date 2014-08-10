MagicLamp::Engine.routes.draw do
  root to: "fixtures#index"
  get "/*name", controller: :fixtures, action: :show
end
