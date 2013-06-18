require 'redmine'

# Patches to the redmine core
require 'journal_patch'
require 'issue_observer_patch'
require 'project_patch'
require 'tracker_patch'
require 'issue_patch'
require 'user_patch'
require 'mailer_patch'
require 'time_entry_patch'
require 'group_patch'
require 'application_controller_patch'
require_dependency 'redmine_scheduler/hooks'

Rails.configuration.to_prepare do

  require_dependency 'application_controller'
  ApplicationController.send(:include, ApplicationControllerPatch) unless ApplicationController.included_modules.include? ApplicationControllerPatch

  require_dependency 'journal'
  Journal.send(:include, JournalPatch) unless Journal.included_modules.include? JournalPatch

  #require_dependency 'issue_observer'
  #IssueObserver.send(:include, IssueObserverPatch) unless IssueObserver.included_modules.include? IssueObserverPatch

  require_dependency 'project'
  Project.send(:include, ProjectPatch) unless Project.included_modules.include? ProjectPatch

  require_dependency 'tracker'
  Tracker.send(:include, TrackerPatch) unless Tracker.included_modules.include? TrackerPatch

  require_dependency 'timeslot'
  require_dependency 'booking'
  require_dependency 'issue'
  Issue.send(:include, IssuePatch) unless Issue.included_modules.include? IssuePatch

  require_dependency 'timesheet'
  require_dependency 'user'
  User.send(:include, UserPatch) unless User.included_modules.include? UserPatch

  require_dependency 'mailer'
  Mailer.send(:include, MailerPatch) unless Mailer.included_modules.include? MailerPatch

  require_dependency 'time_entry'
  TimeEntry.send(:include, TimeEntryPatch) unless TimeEntry.included_modules.include? TimeEntryPatch

  require_dependency 'group'
  Group.send(:include, GroupPatch) unless Group.included_modules.include? GroupPatch

end

Redmine::Plugin.register :redmine_scheduler do
  name 'Redmine Scheduler plugin'
  author 'Milton Reder'
  description 'This is a plugin for Redmine that we use at the DMC.'
  version '0.0.1'
  url 'http://'
  author_url 'http://digitalmedia.jhu.edu'

  # permission :view_skills, :skills => :index
  # permission :edit_skills, { :skills => [:new, :create, :edit, :update, :assign, :link, :unlink, :destroy] }
  # permission :manage_wages, :wages => :all
  menu :application_menu, :stustaff, { :controller => 'stustaff', :action => 'index' }, :caption => 'StuStaff', :if => Proc.new { User.current.is_stustaff? }
  menu :application_menu, :prostaff, { :controller => 'prostaff', :action => 'index' }, :caption => 'ProStaff', :if => Proc.new { User.current.is_prostaff? }
  menu :application_menu, :admstaff, { :controller => 'admstaff', :action => 'index' }, :caption => 'Administrator', :if => Proc.new { User.current.is_admstaff? }

  menu :application_menu, :timeslots, { :controller => 'timeslots', :action => 'find' }, :caption => 'Book Student Time'
  menu :application_menu, :bookings, { :controller => 'bookings', :action => 'index' }, :caption => 'Manage Bookings'

  menu :application_menu, :command, { :controller => 'command', :action => 'index' }, :caption => 'Analze Time', :if => Proc.new { User.current.is_admstaff? || User.current.is_prostaff? }
  menu :application_menu, :student_levels, {:controller=> 'prostaff', :action => 'student_levels'}, :caption => 'Student Levels', :if => Proc.new { User.current.is_prostaff? }
  menu :application_menu, :timesheets, { :controller => 'timesheets' }, :caption => 'Timesheets', :if => Proc.new { User.current.is_admstaff? || User.current.is_stustaff? }
  menu :application_menu, :levels, { :controller => 'levels' }, :caption => 'Skill Levels', :if => Proc.new { User.current.is_admstaff? }
  menu :application_menu, :wages, {:controller => 'wages', :action => 'index'}, :caption => 'Wages', :if => Proc.new { User.current.is_admstaff? }
  menu :application_menu, :skills, {:controller => 'skills', :action => 'index'}, :caption => 'Skills', :if => Proc.new { User.current.is_admstaff? }

  #menu :application_menu, :manage_bookings, { :controller => 'manage', :action => 'index' }, :caption => 'Manage Bookings'
  #menu :application_menu, :booking, { :controller => 'booking', :action => 'index' }, :caption => 'Booking'
  menu :admin_menu, :skills, { :controller => 'skills', :action => 'index' }, :caption => 'Skills'
    #config.active_record.observers = :booking_observer
end