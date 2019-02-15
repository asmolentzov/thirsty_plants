class SessionsController < ApplicationController
  skip_before_action :require_login
  
  def create
    if user = User.from_google_auth(request.env["omniauth.auth"])
      session[:user_id] = user.id
      flash[:success] = "Welcome, gardener, we're glad to have you among the roses."
      redirect_to dashboard_path
    end
  end
end
