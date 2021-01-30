Rails.application.routes.draw do
	mount Pwa::Engine, at: ''
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

		resources :stripe_customers, :path => '/stripe-customers'
		resources :stripe_tokens, :path => '/stripe-tokens'
		resources :book_it, :path => '/book-it'
				
		post "initiateCharge", to: 'charges#initiateCharge', as: "initiateCharge"
		post "newInvoice", to: 'charges#newInvoice', as: "newInvoice"
		post "acceptInvoice", to: 'charges#acceptInvoice', as: "acceptInvoice"
		
		post "trackingNumber", to: 'products#trackingNumber', as: "trackingNumber"
		
		post "checkout", to: 'carts#checkout', as: "checkout"
		post "updateQuantity", to: 'carts#updateQuantity', as: "updateQuantity"
		
		post "join", to: 'home#join', as: "join"
		
		post "requestBooking", to: 'schedule#requestBooking', as: "requestBooking"
		post "acceptBooking", to: 'schedule#acceptBooking', as: "acceptBooking"
		post "cancel", to: 'schedule#cancel', as: "cancel"
		post "confirm", to: 'schedule#confirm', as: "confirm"
		
		get "initiateCharge", to: 'charges#initiateCharge', as: "getinitiateCharge"
		
		get "destroy", to: 'services#destroy', as: "destroyService"

		get "membership", to: 'home#membership', as: "membership"
		get "profile", to: 'home#profile', as: "profile"
		get "authenticateAPI", to: 'home#authenticateAPI', as: "authenticateAPI"

	  authenticated :user do
	    root 'home#profile', as: :authenticated_root
	  end

	  unauthenticated :user do
	    root 'services#index', as: :unauthenticated_root
	  end
	end	
end
