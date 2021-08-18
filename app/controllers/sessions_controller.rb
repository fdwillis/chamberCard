class SessionsController < Devise::SessionsController
  after_action :after_login, :only => :create
  before_action :after_logout, :only => :destroy
  # before_action :after_login, :only => :create
  
  def setSessionVar
    begin
      if setSessionVarParams[:phone]
        session[:phone] = setSessionVarParams[:phone]
        session[:name] = setSessionVarParams[:name]
        session[:email] = setSessionVarParams[:email]
        session[:gender] = setSessionVarParams[:gender]
        session[:size] = setSessionVarParams[:size]

        session[:address] = {
          line1: setSessionVarParams[:line1],
          line2: setSessionVarParams[:line2],
          city: setSessionVarParams[:city],
          state: setSessionVarParams[:state],
          postal_code: setSessionVarParams[:postal_code],
          country: setSessionVarParams[:country],
        }
      end

      if setSessionVarParams[:coupon] == 'clear'
        session[:coupon] = nil
        session[:percentOff] = nil
      elsif setSessionVarParams[:coupon] && couponFound = Stripe::Coupon.retrieve(setSessionVarParams[:coupon], stripe_account: ENV['connectAccount'])
        session[:coupon] = setSessionVarParams[:coupon]
        session[:percentOff] = couponFound['percent_off']
        flash[:success] = "Coupon Applied"
      else
        flash[:success] = "Information Saved"
      end

      redirect_to request.referrer
    rescue Stripe::StripeError => e
      flash[:error] = e.error.message
      redirect_to request.referrer
      return
    rescue Exception => e
      flash[:error] = e
      redirect_to request.referrer
      return
    end
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
    pullCharges

    if resource.manager?
      pullSchedule
      pullOrders
    end

    if response['success']
      flash[:success] = "Welcome"
    else
      reset_session
      current_user = nil
      flash[:error] = response["message"]
      redirect_to new_user_session_path
    end
  end

  private

  def setSessionVarParams
    paramsClean = params.require(:setSessionVar).permit(:name, :email, :coupon, :phone, :line1, :line2, :city, :state, :postal_code, :country, :gender, :size)
    return paramsClean.reject{|_, v| v.blank?}
  end
end