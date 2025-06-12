# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  get '/login' => 'login#login', :as => :login
  get '/login/google', to: redirect('auth/google_oauth2'), as: :google_login
  get '/login/github', to: redirect('auth/github'), as: :github_login
  get '/auth/google_oauth2/callback', to: 'login#google_oauth2', as: :google_oauth2_callback
  get '/auth/github/callback', to: 'login#github', as: :github_callback
  get '/logout' => 'login#logout', :as => :logout
  get '/user/profile', to: 'user#profile', as: :user_profile

  root to: 'map#index', as: 'root'
  get '/state/:state_symbol' => 'map#state', :as => :state_map
  get '/state/:state_symbol/county/:std_fips_code' => 'map#county', :as => :county

  get '/ajax/state/:state_symbol' => 'ajax#counties'

  # Routes for Events
  resources :events, only: %i[index show]
  get '/my_events/new' => 'my_events#new', :as => :new_my_event
  post '/my_events/new', to: 'my_events#create'
  get '/my_events/:id' => 'my_events#edit', :as => :edit_my_event
  match '/my_events/:id', to: 'my_events#update', via: %i[put patch]
  delete '/my_events/:id', to: 'my_events#destroy'

  # Routes for Representatives
  resources :representatives, only: [:index]
  resources :representatives do
    resources :news_items, only: %i[index show]
    resources :my_news_items, except: [:show, :index] do
      collection do
        get 'new', to: 'my_news_items#new', as: :new
        post '/my_news_items/search_news', to: 'my_news_items#search_news', as: :search_news_my_news_items
        post 'create_from_radio', to: 'my_news_items#create_from_radio', as: :create_from_radio
        post 'save_article', to: 'my_news_items#save_article', as: :save_article_my_news_item
      end
    end
    get '/representatives/:representative_id/my_news_item/new' => 'my_news_items#new',
        :as                                                    => :new_my_news_item
        # config/routes.rb
    post '/my_news_item/search_news', to: 'my_news_items#search_news', as: :search_news_my_news_item
    post '/representatives/:representative_id/my_news_item/create_from_radio' => 'my_news_items#create_from_radio'
    match '/representatives/:representative_id/my_news_item/new', to:  'my_news_items#search', via: [:post]
    get '/representatives/:representative_id/my_news_item/:id' => 'my_news_items#edit',
        :as                                                    => :edit_my_news_item
    match '/representatives/:representative_id/my_news_item/:id', to:  'my_news_items#update',
                                                                  via: %i[put patch]
    delete '/representatives/:representative_id/my_news_item/:id', to: 'my_news_items#destroy'

  end
  get '/search/(:address)' => 'search#search', :as => 'search_representatives'
  get '/search/show/(:name)' => 'search#show', :as => 'show_representatives'
end
