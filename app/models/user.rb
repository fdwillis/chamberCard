class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable  

  geocoded_by :address


  def self.timeKit
    t = `curl --request 'GET' --header 'Content-Type: application/json' --url 'https://api.timekit.io/v2/projects' --user ':test_api_key_SicNtNNTHeEpjQIw6G9jpDiaHn9dRwr9'`
    json = Oj.load(t)['data']

    resources = []

    json.each do |j|
      grabResource = `curl --request GET --url "https://api.timekit.io/v2/projects/#{j['id']}/resources" --header 'Content-Type: application/json' --user :test_api_key_SicNtNNTHeEpjQIw6G9jpDiaHn9dRwr9 `

      if !Oj.load(grabResource)['data'].blank? 
        resourceLoaded = Oj.load(grabResource)['data']
        
        availability = `curl --request POST --url https://api.timekit.io/v2/availability --header 'Content-Type: application/json' --user :test_api_key_SicNtNNTHeEpjQIw6G9jpDiaHn9dRwr9 --data '{"project_id":"#{j['id']}"}'`
        debugger
        availabilityLoaded = Oj.load(availability)['data']
        resources << {json: j, resource: resourceLoaded, availability: availabilityLoaded}
      end
    end

    return resources.flatten


  end

  def updateStripeCustomerAPI(params)
    email = params[:email] ? params[:email] : self.email
    stripeName = params[:name]
    phone = params[:phone]
    source = params[:source]

    street = params[:street]

    city = params[:city]
    state = params[:state]
    country = "USA"

# build the address by saving to user and passing param

    curlCall  = `curl -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "email=#{email}&name=#{stripeName}&phone=#{phone}&source=#{source}" -X PATCH #{SITEurl}/v1/stripe-customers/#{self.uuid}`
    curlCall2 = `curl -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "email=#{email}" -X PATCH #{SITEurl}/v1/users/#{self.uuid}`

    response = Oj.load(curlCall)
    response2 = Oj.load(curlCall2)
    
    if !response.blank? && response['success']
      if !response2.blank? && response2['success']
        self.update(email: email, street: street, city: city, state: state, country: country)
        return response
      end
    else
      return response
    end
  end

  def showStripeUserAPI
    curlCall = `curl -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X GET #{SITEurl}/v1/stripe-customers/#{self.uuid}`

    response = Oj.load(curlCall)
    if !response.blank? && response['success']
      return response
    else
      return response
    end
  end

  def attachSourceStripe(tokenSource)

    curlCall = `curl -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "source=#{tokenSource}" -X PATCH #{SITEurl}/v1/stripe-customers/#{self.uuid}`

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

    curlCall = `curl -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "number=#{number}&exp_month=#{exp_month}&exp_year=#{exp_year}&cvc=#{cvc}" #{SITEurl}/v1/stripe-tokens`

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

    curlCall = `curl -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "account_holder_name=#{account_holder_name}&account_number=#{account_number}&routing_number=#{routing_number}" #{SITEurl}/v1/stripe-tokens`

    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      return response
    else
      return response['error']
    end
  end

  def createStripeCustomerAPI

    curlCall = `curl -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "" #{SITEurl}/v1/stripe-customers`

    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      self.update(stripeCustomerID: response['stripeCustomerID'] )
      return response
    else
      return response
    end
  end

  def createUserSessionAPI(password)
    curlCall = `curl -d "email=#{self.email}&password=#{password}" #{SITEurl}/v1/sessions`
    
    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      self.update(username: response['username'] ,accessPin: response['accessPin'] , stripeMerchantID: response['stripeMerchantID'], stripeCustomerID: response['stripeCustomerID'], authentication_token: response['authentication_token'], uuid: response['uuid'] )
      return response
    else
      return response
    end
  end

  def createUserAPI(accessPin)

    curlCall = `curl -d "appName=#{ENV['appName']}&accessPin=#{accessPin}&email=#{self.email}&username=#{self.username}&password=#{self.password}&password_confirmation=#{self.password}" #{SITEurl}/v1/users`

    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      self.update(uuid: response['uuid'],username: response['username'], accessPin: response['accessPin'] )
      return response
    else
      return response
    end
  end

  def updateUserAPI
    email = self.email
    username = self.username

    curlCall = `curl -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "email=#{email}&username=#{username}" -X PATCH #{SITEurl}/v1/users/#{self.uuid}`

    response = Oj.load(curlCall)

    if !response.blank? && response['success']
      return response
    else
      return response
    end
  end

  def deleteUserSessionAPI
    curlCall = `curl -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X DELETE #{SITEurl}/v1/sessions/#{self.uuid}`
    
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
    stripeCustomerID && checkStripeSource
  end
 
  def member?
    paymentOn? && !Stripe::Subscription.list({customer: stripeCustomerID})['data'][0].blank?
  end

  def customer?
    customerAccess.include?(accessPin)
  end

  def virtual?
    virtualAccess.include?(accessPin)     
  end

  def manager?
    managerAccess.include?(accessPin) && !stripeMerchantID.blank?     
  end

  def admin?
    adminAccess.include?(accessPin)     
  end

  def checkStripeSource
    if !stripeCustomerID.blank?
      if manager?
        accountCapabilities = Stripe::Account.retrieve(stripeCustomerID)['capabilities']

        if accountCapabilities['card_payments'] == "active" && accountCapabilities['transfers'] == "active" #charge stripeSubscription to cover heroku fees
          return true
        else
          return false
        end
      else
        stripeCustomer = Stripe::Customer.retrieve(stripeCustomerID)
        #make phone number required for purchase
        if stripeCustomer['default_source']
          return true
        else
          return false
        end
      end
    else
      return false
    end
  end

  def phoneCheck
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

  def self.stripeAmount(string)
    converted = (string.gsub(/[^0-9]/i, '').to_i)

    if string.include?(".")
      dollars = string.split(".")[0]
      cents = string.split(".")[1]

      if cents.length == 2
        stripe_amount = "#{dollars}#{cents}"
      else
        if cents === "0"
          stripe_amount = ("#{dollars}00")
        else
          stripe_amount = ("#{dollars}#{cents.to_i * 10}")
        end
      end

      return stripe_amount
    else
      stripe_amount = converted * 100
      return stripe_amount
    end
  end

  private

  def customerAccess
    return ['customer']
  end

  def virtualAccess
    return ['virtual']
  end

  def managerAccess
    return ['manager']
  end
  
  def adminAccess
    return ['admin' , 'trustee']
  end
end
