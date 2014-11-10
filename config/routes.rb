require 'sidekiq/web'
require_dependency 'scheduler/web'

Rails.application.routes.draw do
  
  # Silver API
  # The frontend Quasar & backstage relies on this endpoint
  scope '/api' do
    
    resources :movies, only: [:index, :show, :update] do
      post :update_scores, on: :member
    end
    
    resources :cinemas, only: [:index, :show, :update] do
      get :schedules, on: :member
    end
    
    resources :sources, only: [:update, :destroy]
    
    resources :schedules, only: [:index]
    
  end

  # Devise login
  devise_for :users

  # Backstage
  get 'backstage/(*path)' => 'backstage#index', as: 'backstage'

  # Sidekiq
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

end
