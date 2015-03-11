require 'uri'

class UsersController < ApplicationController

  def new
    @user = User.new

    flash.keep(:redir_url)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id

      if(flash[:redir_url])
        redirect_to flash[:redir_url]
      else
        redirect_to '/rooms/lobby'
      end
    end
  end


  private

  def user_params
    params.require(:user).permit(:nick)
  end
end
