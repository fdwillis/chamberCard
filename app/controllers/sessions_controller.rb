class SessionsController < Devise::SessionsController
  after_action :after_login, :only => :create
  before_action :before_logout, :only => :destroy
  # before_action :after_login, :only => :create
  

  def before_logout
    logoutAtt = current_user.deleteUserSessionAPI
    
    if logoutAtt['success']
      flash[:notice] = "See ya later"
    else
      flash[:error] = "Trouble Connecting"
    end
  end

  def after_login
    loginAtt = resource.createUserSessionAPI(params[:user][:password])
  	
    if loginAtt['success']
      flash[:success] = "Welcome"
    else
      flash[:error] = "Trouble Connecting"
    end
  end
end