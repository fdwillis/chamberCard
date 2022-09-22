class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?

	def pullSource
		if current_user&.stripeCustomerID
			cards = Stripe::Customer.list_sources(
			  current_user&.stripeCustomerID,
			  {object: 'card'},
			)

			if !cards['data'].blank?
				@cardSource = true
			end
		else
			@cardSource = false
		end
	end

	protected
	def configure_permitted_parameters
	  devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :password, :password_confirmation]) 
  end
end
