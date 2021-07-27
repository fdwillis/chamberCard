class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  geocoded_by :address

  def indexStripeChargesAPI(params)

    if !params['paginateAfter'].blank?
      return `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/api/v1/charges?paginateAfter=#{params['paginateAfter']}`
    elsif !params['paginateBefore'].blank?
      return `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/api/v1/charges?paginateBefore=#{params['paginateBefore']}`
    else
      return `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/api/v1/charges`
    end
  end

  def indexStripeScheduleAPI(params)

    if !params['paginateAfter'].blank?
      return `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/api/v1/schedules?paginateAfter=#{params['paginateAfter']}`
    elsif !params['paginateBefore'].blank?
      return `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/api/v1/schedules?paginateBefore=#{params['paginateBefore']}`
    else
      return `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/api/v1/schedules`
    end
  end

  def indexStripeOrdersAPI(params)

    if !params['paginateAfter'].blank?
      return `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/api/v1/orders?paginateAfter=#{params['paginateAfter']}`
    elsif !params['paginateBefore'].blank?
      return `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/api/v1/orders?paginateBefore=#{params['paginateBefore']}`
    else
      return `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/api/v1/orders`
    end
  end

  def resetPassword(user)
    # get reset password from api then set in brand
    # hashed = Devise.token_generator.generate(User, :reset_password_token)
    # user = User.find_by(email: 'john.doe@mysaas.com')
    # user.reset_password_token = hashed
    # user.reset_password_sent_at = Time.now.utc
    # user.save
  end

  def syncTimekit(params)
    resource_id =  (Rails.env.development? || Rails.env.test?) ? "f8abca72-ec4d-4812-b4b2-156855462017" : timeKitID
    
    start = DateTime.parse(params['start']).rfc3339
    endAt = (DateTime.parse(params['start']) + params['duration'].to_i.minutes).rfc3339

    what = params['what']
    where = params['where']
    description = "Item Purchased: #{params['description']}"
    customerName = params['customerName']
    customerEmail = !params['customerEmail'].blank? ? ( (Rails.env.development? || Rails.env.test?) ? "fdwillis7@gmail.com" : params['customerEmail']) : nil
    customerPhone = params['customerPhone']
    invoiceItem = params['serviceToAccept']

    # timeKitPost = `curl --request POST --header 'Content-Type: application/json' --url https://api.timekit.io/v2/bookings --user :test_api_key_SicNtNNTHeEpjQIw6G9jpDiaHn9dRwr9 --data '{"meta":{"invoiceItem": "#{invoiceItem}", "connectAccount": "#{stripeMerchantID}"},"buffer":"#{ENV['bufferTime']} minutes","resource_id": "#{resource_id}","graph": "instant","start": "#{start}","end": "#{endAt}","what": "#{what}","where": "#{where}","description": "#{description}","customer": {"name": "#{customerName}","email": "#{customerEmail}","phone": "#{customerPhone}"}}'`
    
    if Rails.env.development? || Rails.env.test?
      timeKitPost = `curl --request POST --header 'Content-Type: application/json' --url https://api.timekit.io/v2/bookings --user :#{ENV['timeKitKeyTest']} --data '{"settings": {"allow_double_bookings": true}, "meta":{"invoiceItem": "#{invoiceItem}", "connectAccount": "#{stripeMerchantID}"},"buffer":"#{ENV['bufferTime']} minutes","resource_id": "#{resource_id}","graph": "instant","start": "#{start}","end": "#{endAt}","what": "#{what}","where": "#{where}","description": "#{description}","customer": {"name": "#{customerName}","email": "#{customerEmail}","phone": "#{customerPhone}"}}'`
    end

    if Rails.env.production?
      timeKitPost = `curl --request POST --header 'Content-Type: application/json' --url https://api.timekit.io/v2/bookings --user :#{ENV['timeKitKeyLive']} --data '{"settings": {"allow_double_bookings": true}, "meta":{"invoiceItem": "#{invoiceItem}", "connectAccount": "#{stripeMerchantID}"},"buffer":"#{ENV['bufferTime']} minutes","resource_id": "#{resource_id}","graph": "instant","start": "#{start}","end": "#{endAt}","what": "#{what}","where": "#{where}","description": "#{description}","customer": {"name": "#{customerName}","email": "#{customerEmail}","phone": "#{customerPhone}"}}'`
    end
    
    resourceLoaded = Oj.load(timeKitPost)

    if !resourceLoaded['error']
      return {success: true, timeKitBookingID: resourceLoaded['data']['id']}
    else
      return {success: false, message: resourceLoaded['error']}
    end
  end

  def self.timeKit
    if Rails.env.development? || Rails.env.test?
      resources = `curl --request 'GET' --header 'Content-Type: application/json' --url 'https://api.timekit.io/v2/resources' --user ':#{ENV['timeKitKeyTest']}'`
    end

    if Rails.env.production?
      resources = `curl --request 'GET' --header 'Content-Type: application/json' --url 'https://api.timekit.io/v2/resources' --user ':#{ENV['timeKitKeyLive']}'`
    end

    return Oj.load(resources)['data']
  end

  def resendTwilioPhoneAPI
    

    curlCall  = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X POST #{SITEurl}/api/v1/resend-phone-code`
    response = Oj.load(curlCall)

    if response['success']
      return response
    else
      return response
    end
  end

  def updateStripeCustomerAPI(params)
    email = params[:email] ? params[:email] : self.email
    stripeName = params[:name]
    phone = params[:phone]
    source = params[:source]

    street = params[:street]

    city = params[:city]
    state = params[:state]
    country = "US"

    if street.present?
      saved = self.update(street: street, city: city, state: state, country: country, phone: phone)
    end
    # build the address by saving to user and passing param

    curlCall  = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "country=#{country}&state=#{state}&city=#{city}&line1=#{street}&email=#{email}&name=#{stripeName}&phone=#{phone}&source=#{source}" -X PATCH #{SITEurl}/api/v1/stripe-customers/#{self.uuid}`

    response = Oj.load(curlCall)

    if response['success']
      self.update(phone: phone, email: email)
      return response
    else
      return false
    end
  end

  def showStripeUserAPI
    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/api/v1/stripe-customers/#{self.uuid}`

    response = Oj.load(curlCall)
    if !response.blank? && response['success']
      return response
    else
      return response
    end
  end

  def attachSourceStripe(tokenSource)

    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "source=#{tokenSource}" -X PATCH #{SITEurl}/api/v1/stripe-customers/#{self.uuid}`

    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      return response
    else
      return response['error']
    end
  end

  def createStripeCardTokenAPI(params)
    number = params[:number]
    exp_year = params[:exp_year]
    exp_month = params[:exp_month]
    cvc = params[:cvc]

    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "number=#{number}&exp_month=#{exp_month}&exp_year=#{exp_year}&cvc=#{cvc}" #{SITEurl}/api/v2/stripe-tokens`

    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      return response
    else
      return response['error']
    end
  end

  def createStripeBankTokenAPI(params)
    account_holder_name = params[:account_holder_name]
    account_number = params[:account_number]
    routing_number = params[:routing_number]

    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "account_holder_name=#{account_holder_name}&account_number=#{account_number}&routing_number=#{routing_number}" #{SITEurl}/api/v1/stripe-tokens`

    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      return response
    else
      return response['error']
    end
  end

  def indexStripeCustomerAPI(params)
  
    if !params['paginateAfter'].blank?
      curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/api/v1/stripe-customers?paginateAfter=#{params['paginateAfter']}`
    elsif !params['paginateBefore'].blank?
      curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/api/v1/stripe-customers?paginateBefore=#{params['paginateBefore']}`
    else
      curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/api/v1/stripe-customers`
    end
    
    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      return response
    else
      return response
    end
  end

  def showStripeCustomerAPI(customerID)

    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/api/v1/stripe-customers/#{customerID}`

    response = Oj.load(curlCall)

    if !response.blank? && response['success']
      return response
    else
      return response
    end
  end

  def createStripeCustomerAPI

    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "" #{SITEurl}/api/v1/stripe-customers`

    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      self.update(stripeCustomerID: response['stripeCustomerID'] )
      return response
    else
      return response
    end
  end

  def createUserSessionAPI(user)
    curlCall = `curl -d "email=#{user['email']}&password=#{user['password']}" #{SITEurl}/api/v1/sessions`
    
    response = Oj.load(curlCall)
    
    if response['success']
      self.update(authentication_token: response['authentication_token'], uuid: response['uuid'])
      return response
    else
      return response
    end
  end

  def createUserAPI(params)

    curlCall = `curl -d "uuid=#{SecureRandom.uuid[0..7]}&serviceFee=#{ENV['serviceFee']}&appName=#{ENV['appName']}&phone=#{params['phone']}&accessPin=#{params['accessPin']}&email=#{self.email}&username=#{self.username}&password=#{self.password}&password_confirmation=#{self.password}" #{SITEurl}/api/v1/users`
    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      self.update(uuid: response['uuid'],username: response['username'], accessPin: response['accessPin'], phone: response['phone'], twilioPhoneVerify: response['twilioPhoneVerify'] )
      return response
    else
      return response
    end
  end

  def updateUserAPI
    email = self.email
    username = self.username

    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "email=#{email}&username=#{username}" -X PATCH #{SITEurl}/api/v1/users/#{self.uuid}`

    response = Oj.load(curlCall)

    if !response.blank? && response['success']
      return response
    else
      return response
    end
  end

  def deleteUserSessionAPI
    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X DELETE #{SITEurl}/api/v1/sessions/#{self.uuid}`
    
    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      self.update(authentication_token: nil )
      return response
    else
      return response
    end
  end

  def address
    if !street.blank? && !city.blank? && !state.blank? && !country.blank?
      [street, city, state, country].compact.join(', ')
    else
      return false
    end
  end

  def paymentOn?
    !stripeCustomerID.blank? && !checkStripeSource.blank?
  end

  def owner?
    admin? || (!stripeMerchantID.blank? && stripeMerchantID[5..stripeMerchantID.length] == ENV['appName'][0..15] && manager?)
  end
 
  def member?
    paymentOn? && !Stripe::Subscription.list({customer: stripeCustomerID})['data'][0].blank?
  end

  def customer?
    customerAccess.include?(accessPin)
  end

  def trustee?
    trusteeAccess.include?(accessPin)     
  end

  def manager?
    managerAccess.include?(accessPin)
  end

  def admin?
    adminAccess.include?(accessPin)     
  end
  
  def subscriptionCheck
    if !stripeCustomerID.blank?
      loadCustomer = Stripe::Subscription.list({customer: stripeCustomerID})['data']
#if subscription not active? unpaid? anything but active/present
      return !loadCustomer.blank? ? true : false
    else
      return false
    end
  end

  def checkStripeSource
    if manager?
      accountCapabilities = Stripe::Account.retrieve(stripeMerchantID)['capabilities']

      if accountCapabilities['card_payments'] == "active" && accountCapabilities['transfers'] == "active" #charge stripeSubscription to cover heroku fees
        return true
      else
        return false
      end
    else
      if !stripeCustomerID.blank?
        stripeCustomer = Stripe::Customer.retrieve(stripeCustomerID)
        #make phone number required for purchase
        if stripeCustomer['default_source']
          return true
        else
          return false
        end
      else
        return false
      end
    end
  end

  def phoneCheck
    # twilio
    # if !stripeCustomerID.blank?
    #   if manager?
    #     accountCapabilities = Stripe::Account.retrieve(stripeCustomerID)['capabilities']

    #     if accountCapabilities['card_payments'] == "active" && accountCapabilities['transfers'] == "active" #charge stripeSubscription to cover heroku fees
    #       return true
    #     else
    #       return false
    #     end
    #   else
    #     stripeCustomer = Stripe::Customer.retrieve(stripeCustomerID)
    #     #make phone number required for purchase
    #     if stripeCustomer['default_source']
    #       return true
    #     else
    #       return false
    #     end
    #   end
    # else
    #   return false
    # end
  end

  private

  def customerAccess
    return ['customer']
  end

  def trusteeAccess
    return ['trustee']
  end

  def managerAccess
    return ['manager']
  end
  
  def adminAccess
    return ['admin' , 'trustee']
  end
end
