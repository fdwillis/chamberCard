class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # after_create :createUserAPI

  def createUserAPI

    curlCall = `curl -d "email=#{self.email}&password=#{self.password}&password_confirmation=#{self.password}" #{SITEurl}/v1/users`

    response = Oj.load(curlCall)

    self.update_attributes(uuid: response['uuid'] )
   
    return response
  end

  def createUserSessionAPI(password)
    curlCall = `curl -d "email=#{self.email}&password=#{password}" #{SITEurl}/v1/sessions`
    
    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      self.update_attributes(authentication_token: response['authentication_token'] )
      return response
    else
      return false
    end
  end

  def deleteUserSessionAPI
    response = `curl -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X DELETE #{SITEurl}/v1/sessions/#{self.uuid}`
    
    Oj.load(response)
  end
end
