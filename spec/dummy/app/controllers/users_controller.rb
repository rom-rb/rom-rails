class UsersController < ApplicationController

  def index
    render locals: { users: rom.read(:users).to_a }
  end

end
