RedmineApp::Application.routes.draw do
  resources :repairs, :skillcats, :skills, :wages, :reminders

  resources :fines do
    member do
      post 'pay'
    end
  end

  resources :bookings do
    member do
      put 'cancel'
      #post 'new'
    end
  end

  resources :levels do
    member do
      delete 'delete'
    end

    collection do
      get 'my_levels'
      post 'bulk_create'
    end
  end

  resources :timesheets do
    member do
      get 'print'
      put 'submit', 'approve', 'reject'
      post 'new'
      delete 'delete'
    end
  end

  resources :timeslots do
    collection do
      get 'find'
    end

    member do
      get 'book'
    end
  end

  get 'command', to: 'command#index'
  get 'stustaff', to: 'stustaff#index'

  get 'prostaff', to: 'prostaff#index'
  get 'student_levels', to: 'prostaff#student_levels'
  get 'admstaff', to: 'admstaff#index'
end

