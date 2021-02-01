class SessionsController < Devise::SessionsController
  after_action :after_login, :only => :create
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
    response = resource.createUserSessionAPI(params[:user][:password])
    if response['success']
      flash[:success] = "Welcome"
    else
      flash[:alert] = "Trouble Connecting. Some data will not display."
    end
  end
end