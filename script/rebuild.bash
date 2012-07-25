#!/bin/bash

rm db/development.sqlite3
rake db:migrate
rake redmine:load_default_data
rake db:migrate:plugins
script/runner vendor/plugins/redmine_scheduler/db/seeds.rb
script/runner vendor/plugins/redmine_scheduler/script/add_shifts.rb
#passenger start
exit 0
