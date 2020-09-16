class RegistrationsController < Devise::RegistrationsController
  after_action :createAccount 

  protected

  def createAccount
    if resource.persisted? # user is created successfuly
      createAtt = resource.createUserAPI(params[:user])

      if createAtt['success']
      	userFound = User.find_by(email: createAtt['email'])
      	userFound.update_attributes(uuid: createAtt['uuid'])
      	flash[:notice] = "Created account"
      end
    end
  end
end