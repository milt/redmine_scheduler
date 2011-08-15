class AddTimeToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :start_time, :datetime
    add_column :issues, :end_time, :datetime
  end

  def self.down
    remove_column :issues, :end_time
    remove_column :issues, :start_time
  end
end
