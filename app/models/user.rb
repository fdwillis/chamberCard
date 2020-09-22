class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable  

  def updateStripeUserAPI(params)
    email = params[:email]
    phone = params[:phone]
    source = params[:source]

    curlCall = `curl -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -d "number=#{number}&exp_month=#{exp_month}&exp_year=#{exp_year}&cvc=#{cvc}" #{SITEurl}/v1/stripe-customers/#{self.uuid}`

    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      return response
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
      self.update_attributes(stripeSourceVerified: response['stripeSourceVerified'])
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
      self.update_attributes(stripeUserID: response['stripeUserID'] )
      return response
    else
      return response
    end
  end

  def createUserSessionAPI(password)
    curlCall = `curl -d "email=#{self.email}&password=#{password}" #{SITEurl}/v1/sessions`
    
    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      self.update_attributes(authentication_token: response['authentication_token'], uuid: response['uuid'] )
      return response
    else
      return response
    end
  end

  def deleteUserSessionAPI
    curlCall = `curl -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X DELETE #{SITEurl}/v1/sessions/#{self.uuid}`
    
    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      self.update_attributes(authentication_token: nil )
      return response
    else
      return response
    end
  end
end
