Rails.application.routes.draw do
	mount Pwa::Engine, at: '/'
	mount Split::Dashboard, at: 'split'

	
  devise_for :users, path: '/', path_names: { sign_in: 'auth/login', sign_out: 'auth/logout', sign_up: 'auth/sign-up' }, controllers: { registrations: 'registrations', sessions: 'sessions'} do
  	get '/auth/logout' => 'devise/sessions#destroy'
  end

	devise_scope :user do
		resources :charges
		resources :schedule
		resources :orders
		resources :carts
	
		resources :services
		resources :products
		resources :pricing
		resources :checkout

		resources :stripe_customers, :path => '/customers'
		resources :stripe_tokens, :path => '/stripe-tokens'
				
		post "initiateCharge", to: 'charges#initiateCharge', as: "initiateCharge"
		post "newInvoice", to: 'charges#newInvoice', as: "newInvoice"
		post "acceptInvoice", to: 'charges#acceptInvoice', as: "acceptInvoice"
		
		post "trackingNumber", to: 'products#trackingNumber', as: "trackingNumber"
		
		# post "checkout-anon", to: 'carts#checkout_anon', as: "checkout-anon"
		# post "checkout", to: 'carts#checkout', as: "checkout"
		post "updateQuantity", to: 'carts#updateQuantity', as: "updateQuantity"
		
		post "join", to: 'home#join', as: "join"
		post "verify-phone", to: 'home#verifyPhone', as: "verifyPhone"
		
		post "resend-code", to: 'stripe_customers#resendCode', as: "resendCode"
		post "requestBooking", to: 'schedule#requestBooking', as: "requestBooking"
		post "acceptBooking", to: 'schedule#acceptBooking', as: "acceptBooking"
		post "cancel-timekit", to: 'schedule#timeKitCancel', as: "cancel-timekit-ui"
		post "cancelSub", to: 'home#cancelSub', as: "cancelSub"
		post "completed", to: 'schedule#completed', as: "completed"
		post "confirm", to: 'schedule#confirm', as: "confirm"
		post "customer-pay", to: 'charges#customerPay', as: "customer-pay"
		
		get "success", to: 'checkout#success', as: "success"
		get "cancel", to: 'checkout#cancel', as: "cancel"

		get "initiateCharge", to: 'charges#initiateCharge', as: "getinitiateCharge"
		get "pay-now", to: 'charges#payNow', as: "pay-now"
		
		get "destroy", to: 'services#destroy', as: "destroyService"

		get "profile", to: 'home#profile', as: "profile"
		get "membership", to: 'home#membership', as: "membership"
		get "verify-phone", to: 'home#verifyPhone'
		get "authenticateAPI", to: 'home#authenticateAPI', as: "authenticateAPI"

	  authenticated :user do
	    root 'home#profile', as: :authenticated_root
	  end

	  unauthenticated :user do
	    root 'registrations#new', as: :unauthenticated_root
	  end
	end	
end
