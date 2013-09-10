#!/bin/bash

rm db/redmine_development.sqlite3
rake db:migrate
rake redmine:load_default_data
rake redmine:plugins:migrate
rake redmine_scheduler:load_default_data
rails r plugins/redmine_scheduler/script/add_people_and_groups.rb
rails r plugins/redmine_scheduler/script/add_shifts.rb

exit 0
