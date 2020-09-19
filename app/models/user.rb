class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable  
  # after_create :createUserAPI

  def createUserAPI

    curlCall = `curl -d "email=#{self.email}&username=#{self.username}&password=#{self.password}&password_confirmation=#{self.password}" #{SITEurl}/v1/users`

    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      self.update_attributes(accessPin: response['accessPin'] )
      return response
    else
      return false
    end
  end

  def createUserSessionAPI(password)
    curlCall = `curl -d "email=#{self.email}&password=#{password}" #{SITEurl}/v1/sessions`
    
    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      self.update_attributes(authentication_token: response['authentication_token'], uuid: response['uuid'] )
      return response
    else
      return false
    end
  end

  def deleteUserSessionAPI
    curlCall = `curl -H "bxxkxmxppAuthtoken: #{self.authentication_token}" -X DELETE #{SITEurl}/v1/sessions/#{self.uuid}`
    
    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      self.update_attributes(authentication_token: nil )
      return response
    else
      return false
    end
  end
end
