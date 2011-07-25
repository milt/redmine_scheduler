require 'redmine'

# Patches to the redmine core for User, Issue HABTM relationships
require 'issue_patch'
require 'user_patch'

Redmine::Plugin.register :redmine_scheduler do
  name 'Redmine Scheduler plugin'
  author 'Milton Reder'
  description 'This is a plugin for Redmine that allows unauthenticated users to book shift time.'
  version '0.0.1'
  url 'http://'
  author_url 'http://digitalmedia.jhu.edu'
end
