class SessionsController < Devise::SessionsController
  after_action :after_login, :only => :create
  before_action :before_logout, :only => :destroy
  # before_action :after_login, :only => :create
  

  def before_logout
    logoutAtt = current_user.deleteUserSessionAPI
    
    if logoutAtt['success']
      flash[:notice] = "Welcome"
    end
  end

  def after_login
    loginAtt = resource.createUserSessionAPI(params[:user][:password])
  	
    if loginAtt['success']
      flash[:success] = "Welcome"
    else
      sign_out resource
      flash[:error] = "Trouble Connecting"
    end
  end
end