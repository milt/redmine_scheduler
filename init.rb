require 'redmine'

#this is matt changing some stuff
# Patches to the redmine core for User, Issue HABTM relationships
require 'issue_patch'
require 'user_patch'
require 'mailer_patch'
require 'tracker_patch'
require 'time_entry_patch'
require_dependency 'redmine_scheduler/hooks'

 Dispatcher.to_prepare :redmine_scheduler do
   Issue.send(:include, IssuePatch)
   User.send(:include, UserPatch)
   Mailer.send(:include, MailerPatch)
   Tracker.send(:include, TrackerPatch)
   TimeEntry.send(:include, TimeEntryPatch)
 end

Redmine::Plugin.register :redmine_scheduler do
  name 'Redmine Scheduler plugin'
  author 'Milton Reder'
  description 'This is a plugin for Redmine that allows unauthenticated users to book shift time.'
  version '0.0.1'
  url 'http://'
  author_url 'http://digitalmedia.jhu.edu'

  # permission :view_skills, :skills => :index
  # permission :edit_skills, { :skills => [:new, :create, :edit, :update, :assign, :link, :unlink, :destroy] }
  # permission :manage_wages, :wages => :all
  menu :application_menu, :manage, { :controller => 'manage', :action => 'today' }, :caption => 'Staff'
  #menu :application_menu, :command, { :controller => 'command', :action => 'index' }, :caption => 'ProStaff'
  #menu :application_menu, :manage_bookings, { :controller => 'manage', :action => 'index' }, :caption => 'Manage Bookings'
  #menu :application_menu, :booking, { :controller => 'booking', :action => 'index' }, :caption => 'Booking'
  menu :admin_menu, :skills, { :controller => 'skills', :action => 'index' }, :caption => 'Skills'
    #config.active_record.observers = :booking_observer
end