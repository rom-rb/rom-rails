Dummy::Application.routes.draw do
  get '/users' => 'users#index'
  post '/users' => 'users#create'
  get '/users/new' => 'users#new'
  get '/users/search' => 'users#search'
  get '/users/ping' => 'users#ping'
end
