class RegistrationsController < ApplicationController 

  def new
    pullPayouts = []
    investedAmountRunning = 0
    validPaymentIntents = Stripe::PaymentIntent.list()['data'].map{|d| (!d['metadata']['percentToInvest'].blank?) ? (pullPayouts.append(d)) : next}

    pullPayouts.each do |payint|
      if !payint['metadata'].blank? && payint['metadata']['percentToInvest'].to_i > 0 
        amountForDeposit = payint['amount'] - (payint['amount']*0.029).to_i + 30
        investedAmount = amountForDeposit * (payint['metadata']['percentToInvest'].to_i * 0.01)
        investedAmountRunning += investedAmount
      end
    end

    @amountInvested = investedAmountRunning
  end

  def create
    begin
            
      curlCall = User.pipeline(params['newRegistration'])

      if curlCall['success']
        newUser = User.create(userParams(curlCall['user']).merge({'password'=> params['newRegistration']['password'],
                                                                  'phone' => params['newRegistration']['phone_number']}))
        sign_in(:user, newUser)
        flash[:success] = "Your Card Has Been Ordered! \n Welcome To Netwerth!"
        redirect_to profile_path
        return
      end
    rescue Stripe::StripeError => e
      render json: {
        error: e.error.message,
        success: false
      }
      flash[:error] = e
      redirect_to request.referrer
      return
    rescue Exception => e
      render json: {
        message: e,
        success: false
      }
      flash[:error] = e
      redirect_to request.referrer
      return
    end
  end

  private

  def userParams(dataX)
    paramsClean = dataX.slice('stripeCustomerID', 'phone_number', 'accessPin', 'twilioPhoneVerify', 'referredBy', 'authentication_token', 'uuid', 'email', 'authentication_token')
    return paramsClean.reject{|_, v| v.blank?}
  end
end