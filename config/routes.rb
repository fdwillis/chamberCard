Rails.application.routes.draw do
	mount Pwa::Engine, at: ''
	mount Split::Dashboard, at: 'split'

	
  devise_for :users, path: '/', path_names: { sign_in: 'auth/login', sign_out: 'auth/logout', sign_up: 'auth/sign-up' }, controllers: { registrations: 'registrations', sessions: 'sessions'} do
  	get '/auth/logout' => 'devise/sessions#destroy'
  end

	devise_scope :user do
		resources :charges
		resources :schedule
		resources :carts
		resources :services do
			resources :pricing, :path => '/pricing'
		end
		resources :stripe_customers, :path => '/stripe-customers'
		resources :stripe_tokens, :path => '/stripe-tokens'
		resources :book_it, :path => '/book-it'
		
		post "bookingRequest", to: 'book_it#bookingRequest', as: "bookingRequest"
		
		post "initiateCharge", to: 'charges#initiateCharge', as: "initiateCharge"
		post "newInvoice", to: 'charges#newInvoice', as: "newInvoice"
		post "acceptInvoice", to: 'charges#acceptInvoice', as: "acceptInvoice"
		
		post "cancel", to: 'schedule#cancel', as: "cancel"
		post "acceptRequest", to: 'schedule#acceptRequest', as: "acceptRequest"
	
		post "checkout", to: 'carts#checkout', as: "checkout"
		
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
