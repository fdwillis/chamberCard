class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable  

  geocoded_by :address


  TIMEKITResources = [
    "7e2c060a-bcfa-4e29-a8e0-8fe7e0e1a4db",
  ]


  def self.syncTimekit
#     curl --request POST \
#   --header 'Content-Type: application/json' \
#   --url https://api.timekit.io/v2/bookings \
#   --user :live_api_key_7nzvc7wsBQQISLeFSVhROys9V1bUJ1z7 \
#   --data '{
#   "resource_id": "d187d6e0-d6cb-409a-ae60-45a8fd0ec879",
#   "graph": "confirm",
#   "start": "2018-08-12T21:30:00-07:00",
#   "end": "2018-08-12T22:15:00-07:00",
#   "what": "Catch the lightning",
#   "where": "Courthouse, Hill Valley, CA 95420, USA",
#   "description": "The lightning strikes at 10:04 PM exactly! I need you to be there Doc!",
#   "customer": {
#     "name": "Marty McFly",
#     "email": "marty.mcfly@timekit.io",
#     "phone": "(916) 555-4385",
#     "voip": "McFly",
#     "timezone": "America/Los_Angeles"
#   }
# }'
  end


  def self.timeKit
    t = `curl --request 'GET' --header 'Content-Type: application/json' --url 'https://api.timekit.io/v2/projects' --user ':test_api_key_SicNtNNTHeEpjQIw6G9jpDiaHn9dRwr9'`
    json = Oj.load(t)['data']

    resources = []

    json.each do |j|
      if j['name'] == ENV['appName']
        grabResource = `curl --request GET --url "https://api.timekit.io/v2/projects/#{j['id']}/resources" --header 'Content-Type: application/json' --user :test_api_key_SicNtNNTHeEpjQIw6G9jpDiaHn9dRwr9 `
        resourceLoaded = Oj.load(grabResource)['data']

        if !resourceLoaded.blank? 
          resourceLoaded.each do |res|
            res



            availability = `curl --request POST --url https://api.timekit.io/v2/availability --header 'Content-Type: application/json' --user :test_api_key_SicNtNNTHeEpjQIw6G9jpDiaHn9dRwr9 --data '{"mode": "roundrobin_random","resources": ["#{res}"],"length": "4 hours","from": "3 days","to": "4 weeks","buffer": "30 minutes","ignore_all_day_events": true}'`



            availabilityLoaded = Oj.load(availability)['data']

            debugger
            resources << {project: j, resource: resourceLoaded, availability: availabilityLoaded}
          end
        end
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

    saved = self.update(street: street, city: city, state: state, country: country)
    # build the address by saving to user and passing param

    curlCall  = `curl -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "email=#{email}&name=#{stripeName}&phone=#{phone}&source=#{source}" -X PATCH #{SITEurl}/v1/stripe-customers/#{self.uuid}`

    response = Oj.load(curlCall)

    if response['success'] && saved
      return response
    else
      return false
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
    !stripeCustomerID.blank? && !checkStripeSource.blank?
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
        accountCapabilities = Stripe::Account.retrieve(stripeMerchantID)['capabilities']

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
