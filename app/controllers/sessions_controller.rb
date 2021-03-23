class SessionsController < Devise::SessionsController
  before_action :after_login, :only => :create
  before_action :after_logout, :only => :destroy
  # before_action :after_login, :only => :create
  

  def after_logout
    logoutAtt = current_user.deleteUserSessionAPI
    if logoutAtt['success']
      reset_session
      current_user = nil
      flash[:success] = "See ya later"
    else
      reset_session
      current_user = nil
      flash[:alert] = "You've been signed out"
    end
  end

  def after_login
    response = User.createUserSessionAPI(params[:user])
    if response['success']
      flash[:success] = "Welcome"
    else
      flash[:alert] = response['message']
    end
  end
end