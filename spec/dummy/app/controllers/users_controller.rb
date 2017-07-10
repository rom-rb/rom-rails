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
    render :new, locals: { user: UserForm.new }
  end

  def create
    user_form = UserForm.new(params[:user].permit!)

    if user_form.valid?
      rom.commands[:users].create.call(user_form.to_h)
      redirect_to :users
    else
      render :new, locals: { user: user_form }
    end
  end

  def edit
    data = rom.relations[:users].where(id: params[:id]).one
    user_form = UserForm.new(data)

    render :edit, locals: { user: user_form }
  end

  def update
    data = rom.relations[:users].where(id: params[:id]).one
    user_form = UserForm.new(data).merge(params[:user].permit!)

    if user_form.valid?
      rom.commands[:users].update.by_id(params[:id]).call(user_form.to_h)
      redirect_to :users
    else
      render :edit, locals: { user: user_form }
    end
  end

  def ping
    head :ok
  end
end
