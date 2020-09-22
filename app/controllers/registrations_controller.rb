class RegistrationsController < Devise::RegistrationsController
  after_action :createAccount 

  protected

  def createAccount
    if resource.persisted? # user is created successfuly
      createAtt = resource.createUserAPI
      
      if createAtt['success']

      	
      	auth = resource.createUserSessionAPI(params[:user][:password])
      	if auth['success']

          crypt = ActiveSupport::MessageEncryptor.new(ENV['encryptMeDatax'])
          encrypted_data = crypt.encrypt_and_sign(params[:user][:password])
          resource.update_attributes(encrypted_password: encrypted_data)

	      	flash[:success] = "Created account"
	      else
	      	flash[:notice] = "You will need to verify later"
	      end
      end
    end
  end
end