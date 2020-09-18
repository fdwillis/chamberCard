Rails.application.routes.draw do
	get 'auth/_manifest.json' => 'home#manifest'
	get '_manifest.json' => 'home#manifest'

	get "profile" => 'home#grabProfile'

	# get 'service-worker.js' => 'home#service_worker'
  devise_for :users, path: '/', path_names: { sign_in: 'auth/login', sign_out: 'auth/logout', sign_up: 'auth/sign-up' }, controllers: { registrations: 'registrations', sessions: 'sessions'}
	devise_scope :user do
		
	  authenticated :user do
	    root 'profile#grabProfile', as: :authenticated_root
	  end
    root 'services#index'

	  # unauthenticated do
	  #   root 'devise/sessions#new', as: :unauthenticated_root
	  # end
	end	
end
