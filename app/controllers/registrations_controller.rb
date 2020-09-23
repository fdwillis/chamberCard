class RegistrationsController < Devise::RegistrationsController
  after_action :createAccount 

  protected

  def createAccount
    if resource.persisted? # user is created successfuly
      createAtt = resource.createUserAPI

      if createAtt['success']

      	auth = resource.createUserSessionAPI(params[:user][:password])
      	if auth['success']
	      	flash[:success] = "Created account"
	      else
          flash[:alert] = "You will need to verify later"
        end
      else
        resource.destroy!
      	flash[:alert] = createAtt['error']
      end
    end
  end
end