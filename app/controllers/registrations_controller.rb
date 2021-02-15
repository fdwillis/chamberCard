class RegistrationsController < Devise::RegistrationsController
  after_action :createAccount 

  protected

  def createAccount
    if resource.persisted? && !params[:user][:accessPin].blank? # user is created successfuly
      createAtt = resource.createUserAPI(params[:user])

      if createAtt['success']
        auth = resource.createUserSessionAPI(params[:user][:password])
        
        if auth['success']
          flash[:success] = "Created account"
        else
          flash[:alert] = "You will need to verify later"
        end
      else
        flash[:alert] = createAtt['error']
        resource.destroy!
      end
    else
      flash[:alert] = resource.errors.full_messages.join(", ")
      resource.destroy!
    end
  end
end