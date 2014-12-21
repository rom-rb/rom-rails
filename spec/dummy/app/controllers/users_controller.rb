class UsersController < ApplicationController
  rescue_from ROM::Rails::RelationParamsMissingError do
    head :bad_request
  end

  relation 'users.index', only: :index
  relation 'users.by_name', only: :search, requires: :name

  def index
    render
  end

  def search
    render :index
  end

  def ping
    head :ok
  end
end
