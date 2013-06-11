RedmineApp::Application.routes.draw do
  resources :repairs

  get 'stustaff', to: 'stustaff#index'

  get 'prostaff', to: 'prostaff#index'
  get 'student_levels', to: 'prostaff#student_levels'
  get 'admstaff', to: 'admstaff#index'
end

