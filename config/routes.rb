RedmineApp::Application.routes.draw do
  resources :repairs, :skillcats, :skills, :wages

  resources :bookings do
    member do
      put 'cancel'
    end
  end

  resources :levels do
    member do
      get 'my_levels'
      post 'bulk_create'
    end
  end

  resources :timesheets do
    member do
      post 'print'
      put 'submit', 'approve', 'reject'
    end
  end

  resources :timeslots do
    member do
      get 'find'
      get 'book'
    end
  end

  get 'stustaff', to: 'stustaff#index'

  get 'prostaff', to: 'prostaff#index'
  get 'student_levels', to: 'prostaff#student_levels'
  get 'admstaff', to: 'admstaff#index'
end

