class AddTimesheetToTimeEntries < ActiveRecord::Migration
  def self.up
    add_column :time_entries, :timesheet_id, :integer
  end

  def self.down
    remove_column :time_entries, :timesheet_id
  end
end
