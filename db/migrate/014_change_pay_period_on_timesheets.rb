class ChangePayPeriodOnTimesheets < ActiveRecord::Migration
  def self.up
    remove_column :timesheets, :pay_period
    add_column :timesheets, :weekof, :datetime
  end

  def self.down
    add_column :timesheets, :pay_period, :datetime
    remove_column :timesheets, :weekof
  end
end