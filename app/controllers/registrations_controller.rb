class RegistrationsController < Devise::RegistrationsController
  after_action :createAccount 

  protected

  def createAccount
    if resource.persisted? && !params[:user][:accessPin].blank? # user is created successfuly
      
      createAtt = resource.createUserAPI(params[:user][:accessPin])

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
    else
      resource.destroy!
      flash[:alert] = "Please Choose An Account Type"
    end
  end
end