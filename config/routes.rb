Rails.application.routes.draw do
	get 'auth/_manifest.json' => 'home#manifest'
	get '_manifest.json' => 'home#manifest'
	
  devise_for :users, path: '/', path_names: { sign_in: 'auth/login', sign_out: 'auth/logout', sign_up: 'auth/sign-up' }, controllers: { registrations: 'registrations', sessions: 'sessions'}

	# get 'service-worker.js' => 'home#service_worker'

	devise_scope :user do
		resources :charges
		resources :schedule
		resources :services
		resources :stripe_customers, :path => '/stripe-customers'
		resources :stripe_tokens, :path => '/stripe-tokens'
		resources :book_it, :path => '/book-it'
		
		post "bookingRequest", to: 'book_it#bookingRequest', as: "bookingRequest"
		
		get "profile", to: 'home#profile', as: "profile"
	  authenticated :user do
	    root 'home#profile', as: :authenticated_root
	  end

	  unauthenticated :user do
	    root 'services#index', as: :unauthenticated_root
	  end
	end	
end
