class SessionsController < Devise::SessionsController
  after_action :after_login, :only => :create
  before_action :before_logout, :only => :destroy
  # before_action :after_login, :only => :create
  

  def before_logout
    logoutAtt = current_user.deleteUserSessionAPI
    
    if logoutAtt['success']
      flash[:notice] = "See ya later"
    else
      flash[:notice] = "Trouble Connecting"
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