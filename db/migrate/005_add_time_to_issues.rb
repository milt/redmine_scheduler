class AddTimeToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :start_time, :time
    add_column :issues, :end_time, :time
  end

  def self.down
    remove_column :issues, :end_time
    remove_column :issues, :start_time
  end
end
