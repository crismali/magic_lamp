# frozen_string_literal: true

MagicLamp::Engine.routes.draw do
  root to: "fixtures#index"
  get "/lint", to: "lint#index"
  get "/*name", to: "fixtures#show"
end
