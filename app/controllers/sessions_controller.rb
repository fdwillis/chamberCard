class SessionsController < Devise::SessionsController
  after_action :after_login, :only => :create
  before_action :before_logout, :only => :destroy
  # before_action :after_login, :only => :create
  

  def before_logout
    logoutAtt = current_user.deleteUserSessionAPI

    if logoutAtt['success']
      flash[:success] = "See ya later"
    else
      flash[:alert] = "You've been signed out"
      current_user.update_attributes(authentication_token: nil )
      redirect_to destroy_user_session_path(current_user)
    end
  end

  def after_login
    response = resource.createUserSessionAPI(params[:user][:password])
  	
    if !response.blank? && response['success']
      flash[:success] = "Welcome"
    else
      flash[:notice] = "Trouble Connecting. Some data will not display."
    end
  end
end