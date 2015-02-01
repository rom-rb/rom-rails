Dummy::Application.routes.draw do
  get '/users' => 'users#index', as: :users
  post '/users' => 'users#create'
  get '/users/:id/edit' => 'users#edit'
  patch '/users/:id' => 'users#update', as: :user
  get '/users/new' => 'users#new'
  get '/users/search' => 'users#search'
  get '/users/ping' => 'users#ping'
end
