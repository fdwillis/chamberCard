Rails.application.routes.draw do
  devise_for :users, path: '/', path_names: { sign_in: 'auth/login', sign_out: 'auth/logout', sign_up: 'auth/sign-up' }, controllers: { registrations: 'registrations', sessions: 'sessions'}
	root to: "home#home"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
