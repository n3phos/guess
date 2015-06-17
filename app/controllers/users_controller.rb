
class UsersController < ApplicationController

  def new
    @user = User.new

    flash.keep(:redir_url)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      #session[:expires_at] = Time.current + 6.months
      cookies[:first_visit] = {:value => true, :expires => Time.now + 6.months }

      if(flash[:redir_url])
        redirect_to flash[:redir_url]
      else
        redirect_to '/rooms/lobby'
      end
    else
      flash[:error] = @user.errors.first[1]
      render 'new'
    end
  end

  def update
    if(current_user.update_attributes(user_params))
      redirect_to '/rooms/lobby'
    else
      flash[:error] = current_user.errors.first[1]
      @current_user = User.find(current_user.id)
      render 'new'
    end
  end


  private

  def user_params
    params.require(:user).permit(:nick)
  end
end
