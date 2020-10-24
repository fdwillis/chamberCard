class SessionsController < Devise::SessionsController
  after_action :after_login, :only => :create
  before_action :after_logout, :only => :destroy
  # before_action :after_login, :only => :create
  

  def after_logout
    logoutAtt = current_user.deleteUserSessionAPI
    if logoutAtt['success']
      current_user = nil
      reset_session
      flash[:success] = "See ya later"
    else
      flash[:alert] = "You've been signed out"
      current_user.update_attributes(authentication_token: nil )
    end
  end

  def after_login
    response = resource.createUserSessionAPI(params[:user][:password])
  	
    if !response.blank? && response['success']
      response2 = resource.updateUserAPI
      flash[:success] = "Welcome"
    else
      flash[:alert] = "Trouble Connecting. Some data will not display."
    end
  end
end