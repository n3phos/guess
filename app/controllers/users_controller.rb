class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to :home
    end
  end

  private

  def user_params
    params.require(:user).permit(:nick)
  end
end
