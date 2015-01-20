class UsersController < ApplicationController
  rescue_from ROM::Rails::RelationParamsMissingError do
    head :bad_request
  end

  relation 'users.index', only: :index
  relation 'users.by_name', only: :search, requires: :name

  def index
    render
  end

  def new
    render :new, locals: { user: UserForm.build }
  end

  def create
    user_form = UserForm.build(params[:user]).save

    if user_form.success?
      redirect_to :users
    else
      render :new, locals: { user: user_form }
    end
  end

  def search
    render :index
  end

  def ping
    head :ok
  end
end
