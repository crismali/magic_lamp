MagicLamp::Engine.routes.draw do
  root to: "fixtures#index"
  get "/lint", to: "lint#index"
  get "/*name", controller: :fixtures, action: :show
end
