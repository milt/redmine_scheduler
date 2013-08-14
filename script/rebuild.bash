#!/bin/bash

rm db/development.sqlite3
rake db:migrate
rake redmine:load_default_data
rake redmine:plugins:migrate
rake redmine_scheduler:load_default_data
rails r plugins/redmine_scheduler/script/add_shifts.rb

exit 0
