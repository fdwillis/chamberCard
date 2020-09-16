class RegistrationsController < Devise::RegistrationsController
  after_action :createAccount 

  protected

  def createAccount
    if resource.persisted? # user is created successfuly
      resource.createUserAPI(params[:user])
    	debugger
    end
  end
end