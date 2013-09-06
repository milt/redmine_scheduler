desc 'Steps to take post chili migration'

namespace :redmine_scheduler do
  task :post_chili_migration => :environment do
    #poster project, trackers
    poster_project_params = {
      :name => "Poster Printing",
      :description => "Project for printing posters.",
      :homepage => "",
      :is_public => false,
      :identifier => "poster-print",
      :status => 1
    }

    poster_project = Project.create(poster_project_params)


    poster_print_tracker_params = {
      :name => "Poster Print",
      :is_in_chlog => false,
      :is_in_roadmap => false
    }

    poster_print_tracker = Tracker.create(poster_print_tracker_params)

    IssueStatus.create!(name: "Printed", is_closed: false, is_default: false)
    IssueStatus.create!(name: "Picked Up", is_closed: true, is_default: false)
  end
end