class SessionsController < Devise::SessionsController
  after_action :after_login, :only => :create
  # before_action :after_login, :only => :create

  

  def after_login
    loginAtt = User.createUserSessionAPI(params)
  	
    if loginAtt['success']
      userFound = User.find_by(uuid: loginAtt['uuid'])
      userFound.update_attributes(authentication_token: loginAtt['authentication_token'])
      flash[:notice] = "Welcome"
    end
  end
end