class SessionsController < Devise::SessionsController
  after_action :after_login, :only => :create
  before_action :after_logout, :only => :destroy
  # before_action :after_login, :only => :create
  
  def setSessionVar
    session[:phone] = setSessionVarParams[:phone]
    session[:coupon] = setSessionVarParams[:coupon]
    session[:address] = {
      line1: setSessionVarParams[:line1],
      line2: setSessionVarParams[:line2],
      city: setSessionVarParams[:city],
      state: setSessionVarParams[:state],
      postal_code: setSessionVarParams[:postal_code],
      country: setSessionVarParams[:country],
    }
    flash[:success] = "Information Saved"
    redirect_to request.referrer
  end
  
  def after_logout
    logoutAtt = current_user.deleteUserSessionAPI
    if logoutAtt['success']
      reset_session
      current_user = nil
      flash[:success] = "See ya later"
    end
  end

  def after_login
    response = resource.createUserSessionAPI(params[:user])

    if response['success']
      flash[:success] = "Welcome"
    end
  end

  private

  def setSessionVarParams
    paramsClean = params.require(:setSessionVar).permit(:coupon, :phone, :line1, :line2, :city, :state, :postal_code, :country)
    return paramsClean.reject{|_, v| v.blank?}
  end
end