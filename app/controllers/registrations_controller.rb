class RegistrationsController < ApplicationController 

  def new
    # paymentIntents = []
    # investedAmountRunning = 0
    # validPaymentIntents = Stripe::PaymentIntent.list(limit: 100)['data'].map{|d| (!d['metadata']['percentToInvest'].blank?) ? (paymentIntents.append(d)) : next}

    # paymentIntents.reject{|e| e['charges']['data'][0]['refunded'] == true}.reject{|e| e['charges']['data'][0]['captured'] == false}.each do |payint|
    #   if !payint['metadata'].blank? && payint['metadata']['percentToInvest'].to_i > 0 
    #     amountForDeposit = payint['amount'] - (payint['amount']*0.029).to_i + 30
    #     investedAmount = amountForDeposit * (payint['metadata']['percentToInvest'].to_i * 0.01)
    #     investedAmountRunning += investedAmount
    #   end
    # end

    # pullPayouts = []
    # @amountInvested = investedAmountRunning
    # topups = Stripe::Topup.list({limit: 100})['data'].map{|d| (!d['metadata']['startDate'].blank? && !d['metadata']['endDate'].blank?) ? (pullPayouts.append(d)) : next}.compact.flatten
    # @topUpSum = topups.map(&:amount).sum
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