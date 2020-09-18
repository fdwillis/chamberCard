Rails.application.routes.draw do
	get 'auth/_manifest.json' => 'home#manifest'
	get '_manifest.json' => 'home#manifest'
	
  devise_for :users, path: '/', path_names: { sign_in: 'auth/login', sign_out: 'auth/logout', sign_up: 'auth/sign-up' }, controllers: { registrations: 'registrations', sessions: 'sessions'}

	# get 'service-worker.js' => 'home#service_worker'

	devise_scope :user do
		get "profile", to: 'home#profile', as: "profile"
		resources :charges
		resources :schedule
		resources :services
		
	  authenticated :user do
	    root 'home#profile', as: :authenticated_root
	  end

	  unauthenticated :user do
	    root 'services#index', as: :unauthenticated_root
	  end
	end	
end
