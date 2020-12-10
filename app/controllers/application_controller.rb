class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?
	before_action :grabCart

	def grabCart
		if current_user&.authentication_token
			curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X GET #{SITEurl}/v1/carts`
			
	    response = Oj.load(curlCall)
	    
	    if !response.blank? && response['success']
	    	@cart = response
	    	
	    end
	  else
	  	@cart = nil
	  end

	end

	protected
	def configure_permitted_parameters
	  devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :password, :password_confirmation]) 
  end
end
