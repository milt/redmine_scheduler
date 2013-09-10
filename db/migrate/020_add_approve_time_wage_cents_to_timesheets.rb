class AddApproveTimeWageCentsToTimesheets < ActiveRecord::Migration
  def self.up
    remove_column :timesheets, :approve_time_wage
    add_column :timesheets, :approve_time_wage_cents, :integer
  end

  def self.down
    remove_column :timesheets, :approve_time_wage_cents
    add_column :timesheets, :approve_time_wage, :float
  end
end
