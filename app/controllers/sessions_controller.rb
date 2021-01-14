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
      current_user = nil
      reset_session
      flash[:alert] = "You've been signed out"
    end
  end

  def after_login
    response = resource.createUserSessionAPI(params[:user][:password])
  	
    if !response.blank? && response['success']
      resource.update(stripeUserID:response['stripeUserID'], stripeSourceVerified:response['stripeSourceVerified'], username:response['username'], email:response['email'],)
      response2 = resource.updateUserAPI
      flash[:success] = "Welcome"
    else
      flash[:alert] = "Trouble Connecting. Some data will not display."
    end
  end
end