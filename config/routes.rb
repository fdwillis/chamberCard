Rails.application.routes.draw do
	mount Pwa::Engine, at: '/'
	mount Split::Dashboard, at: 'split'

	
  devise_for :users, path: '/', path_names: { sign_in: 'auth/login', sign_out: 'auth/logout', sign_up: 'auth/sign-up' }, controllers: { registrations: 'registrations', sessions: 'sessions'} do
  	get '/auth/logout' => 'devise/sessions#destroy'
  end

  authenticated :user do
    root 'home#profile', as: :authenticated_root
  end

  unauthenticated :user do
    root 'products#index'
  end

	devise_scope :user do
		resources :charges
		resources :snapshots
		resources :recordings
		resources :schedule
		resources :orders
		resources :carts
		resources :jobs
	
		resources :services
		resources :products
		resources :pricing
		resources :checkout

		resources :stripe_customers, :path => '/customers'
		resources :stripe_tokens, :path => '/stripe-tokens'
		
		post "zazi", to: 'checkout#zazi', as: "zazi"
				
		post "setSessionVar", to: 'sessions#setSessionVar', as: "set-session-vars"
		post "initiateCharge", to: 'charges#initiateCharge', as: "initiateCharge"
		post "newInvoice", to: 'charges#newInvoice', as: "newInvoice"
		
		post "trackingNumber", to: 'products#trackingNumber', as: "trackingNumber"
		
		# post "checkout-anon", to: 'carts#checkout_anon', as: "checkout-anon"
		# post "checkout", to: 'carts#checkout', as: "checkout"
		post "updateQuantity", to: 'carts#updateQuantity', as: "updateQuantity"
		
		match "/plaid" => "home#plaid", as: :plaid, via: [:get, :post]

		post "join", to: 'home#join', as: "join"
		post "verify-phone", to: 'home#verifyPhone', as: "verifyPhone"
		
		post "resend-code", to: 'stripe_customers#resendCode', as: "resendCode"
		post "requestBooking", to: 'schedule#requestBooking', as: "requestBooking"
		post "acceptBooking", to: 'schedule#acceptBooking', as: "acceptBooking"
		post "cancel-timekit", to: 'schedule#timeKitCancel', as: "cancel-timekit-ui"
		post "cancelSub", to: 'home#cancelSub', as: "cancelSub"
		post "completed", to: 'schedule#completed', as: "completed"
		post "confirm", to: 'schedule#confirm', as: "confirm"
		
		get "/thank-you/:id", to: 'checkout#thankYou', as: "thankYou"
		get "/customers/:id/payments", to: 'charges#payments', as: "payments"
		get "success", to: 'checkout#success', as: "success"
		get "cancel", to: 'checkout#cancel', as: "cancel"

		get "initiateCharge", to: 'charges#initiateCharge', as: "getinitiateCharge"
		get "pay-now", to: 'charges#payNow', as: "pay-now"
		
		get "destroy", to: 'services#destroy', as: "destroyService"

		get "profile", to: 'home#profile', as: "profile"
		get "membership", to: 'home#membership', as: "membership"
		get "verify-phone", to: 'home#verifyPhone'
		get "authenticateAPI", to: 'home#authenticateAPI', as: "authenticateAPI"

	  
	end	
end
