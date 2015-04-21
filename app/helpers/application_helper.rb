module ApplicationHelper
  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def sign_in(user)
    session[:user_id] = user.id
  end
end
