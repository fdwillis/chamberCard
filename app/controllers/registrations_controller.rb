class RegistrationsController < ApplicationController 

  def new
  end

  def create
    begin
            
      curlCall = User.pipeline(params['newRegistration'])

      if curlCall['success']
        newUser = User.create(userParams(curlCall['user']).merge({'password'=> params['newRegistration']['password']}))
        sign_in(:user, newUser)
        flash[:success] = "Payment added"
        redirect_to profile_path
        return
      end

      # cardHolderNew = Stripe::Issuing::Cardholder.create({
      #   type: newRegistrationData['type'],
      #   name: newRegistrationData['name'],
      #   email: newRegistrationData['email'],
      #   phone_number: newRegistrationData['phone_number'],
      #   billing: {
      #     address: {
      #       line1: newRegistrationData['line1'],
      #       city: newRegistrationData['city'],
      #       state: newRegistrationData['state'],
      #       country: "US",
      #       postal_code: newRegistrationData['postal_code'],
      #     },
      #   },
      # })

      # cardNew = Stripe::Issuing::Card.create({
      #   cardholder: cardHolderNew['id'],
      #   currency: 'usd',
      #   type: 'physical',
      #   spending_controls: {spending_limits: {}},
      #   status: 'active',
      #   shipping: {
      #     name: newRegistrationData['name'],
      #     address: {
      #       line1: newRegistrationData['line1'],
      #       city: newRegistrationData['city'],
      #       state: newRegistrationData['state'],
      #       country: "US",
      #       postal_code: newRegistrationData['postal_code'],
      #     }
      #   }
      # })

      # customerViaStripe = Stripe::Customer.create({
      #   description: 'Netwerth Debit Card Holder',
      #   name: newRegistrationData['name'],
      #   email: newRegistrationData['email'],
      #   phone: newRegistrationData['phone_number'],
      #   address: {
      #     line1: newRegistrationData['line1'],
      #     city: newRegistrationData['city'],
      #     state: newRegistrationData['state'],
      #     country: "US",
      #     postal_code: newRegistrationData['postal_code'],
      #   },
      #   metadata: {
      #     cardHolder: cardHolderNew['id'],
      #     issuedCard: cardNew['id'],
      #     percentToInvest: newRegistrationData['percentToInvest'],
      #   }
      # })

      # Stripe::Issuing::Cardholder.update(cardHolderNew['id'], metadata: {stripeCustomerID: customerViaStripe['id']})
      # # make user account so they can access the app and make transfers

      # @user = User.create!(uuid: SecureRandom.uuid[0..7], stripeCustomerID: customerViaStripe['id'], appName: 'netwethCard', accessPin: 'customer', email: newRegistrationData['email'], password: newRegistrationData['password'], password_confirmation: newRegistrationData['password_confirmation'], referredBy: newRegistrationData['referredBy'].nil? ? "admin" : newRegistrationData['referredBy'], phone: newRegistrationData['phone'])

      # render json: {success: true}
            
    rescue Stripe::StripeError => e
      render json: {
        error: e.error.message,
        success: false
      }
    rescue Exception => e
      render json: {
        message: e,
        success: false
      }
    end
  end

  private

  def userParams(dataX)
    paramsClean = dataX.slice('stripeCustomerID', 'phone', 'accessPin', 'twilioPhoneVerify', 'referredBy', 'authentication_token', 'uuid', 'email', 'authentication_token')
    return paramsClean.reject{|_, v| v.blank?}
  end
end