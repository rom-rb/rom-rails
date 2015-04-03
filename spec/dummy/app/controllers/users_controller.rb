class UsersController < ApplicationController
  rescue_from ROM::Rails::RelationParamsMissingError do
    head :bad_request
  end

  def index
    render :index, locals: { users: rom.relation(:users).as(:entity) }
  end

  def search
    render :index, locals: {
      users: rom.relation(:users).as(:entity).by_name(params[:name])
    }
  end

  def new
    render :new, locals: { user: NewUserForm.build }
  end

  def create
    user_form = NewUserForm.build(params[:user]).save

    if user_form.success?
      redirect_to :users
    else
      render :new, locals: { user: user_form }
    end
  end

  def edit
    user_form = UpdateUserForm.build({}, { id: params[:id] })

    render :edit, locals: { user: user_form }
  end

  def update
    user_form = UpdateUserForm.build(params[:user], id: params[:id]).save

    if user_form.success?
      redirect_to :users
    else
      render :edit, locals: { user: user_form }
    end
  end

  def ping
    head :ok
  end
end
