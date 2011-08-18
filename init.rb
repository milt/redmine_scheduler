require 'redmine'

# Patches to the redmine core for User, Issue HABTM relationships
require 'issue_patch'
require 'user_patch'
require_dependency 'redmine_scheduler/hooks'

Redmine::Plugin.register :redmine_scheduler do
  name 'Redmine Scheduler plugin'
  author 'Milton Reder'
  description 'This is a plugin for Redmine that allows unauthenticated users to book shift time.'
  version '0.0.1'
  url 'http://'
  author_url 'http://digitalmedia.jhu.edu'

  permission :view_skills, :skills => :index
  permission :edit_skills, { :skills => [:new, :create, :edit, :update, :assign, :link, :unlink, :destroy] } 
  menu :application_menu, :booking, { :controller => 'booking', :action => 'index' }, :caption => 'Book Lab Coach'
  menu :admin_menu, :skills, { :controller => 'skills', :action => 'index' }, :caption => 'Skills'
end
