#!/bin/bash

#rm db/redmine_development.sqlite3
rake db:migrate
rake redmine:load_default_data
rake redmine:plugins:migrate NAME=redmine_scheduler
rake redmine_scheduler:load_default_data
rails r plugins/redmine_scheduler/script/add_people_and_groups.rb
rails r plugins/redmine_scheduler/script/add_shifts.rb
rails r plugins/redmine_scheduler/script/add_bookings.rb
rails r plugins/redmine_scheduler/script/add_timesheets.rb

exit 0
