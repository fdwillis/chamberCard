class SessionsController < Devise::SessionsController
  after_action :after_login, :only => :create
  before_action :after_logout, :only => :destroy
  # before_action :after_login, :only => :create
  

  def after_logout
    # logoutAtt = current_user.deleteUserSessionAPI
    # debugger
    
    # if logoutAtt['success']
    #   userFound = User.find_by(uuid: logoutAtt['uuid'])
    #   userFound.update_attributes(authentication_token: nil)
    #   flash[:notice] = "Welcome"
    # end
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