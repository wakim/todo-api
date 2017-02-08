Rails.application.routes.draw do
  def user_resources
    resources :items
  end

  namespace :api do
    namespace :v1 do
      resources :users, only: [:show] do
        user_resources
      end

      scope '/:user_id', constraints: { user_id: 'me' }, defaults: { format: 'json' }, as: 'me' do
        user_resources
      end

      match '/:id' => 'users#show', via: :get,
            constraints: { id: 'me' }

      post 'sessions/authenticate', to: 'authentication#authenticate_user'
      post 'sessions/', to: 'authentication#create'
    end
  end
end
