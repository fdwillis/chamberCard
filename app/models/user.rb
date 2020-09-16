class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def createUserAPI(params)
  	email = params['email']
  	password = params['password']
  	password = params['password']
  	password_confirmation = params['password_confirmation']

    response = `curl -d "email=#{email}&password=#{password}&password_confirmation=#{password_confirmation}" #{SITEurl}/v1/users`
    debugger
    Oj.load(response)
  end
end
