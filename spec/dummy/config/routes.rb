Dummy::Application.routes.draw do
  get '/users' => 'users#index'
  get '/users/search' => 'users#search'
  get '/users/ping' => 'users#ping'
end
