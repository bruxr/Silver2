require 'sidekiq/web'
require_dependency 'scheduler/web'

Rails.application.routes.draw do
  
  # Silver API
  # The frontend Quasar & backstage relies on this endpoint
  scope '/api' do
    resources :movies, :cinemas, :schedules
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
