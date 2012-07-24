class AddPaidTimeWageOnTimesheets < ActiveRecord::Migration
  def self.up
    add_column :timesheets, :paid_time_wage, :float
  end

  def self.down
    remove_column :timesheets, :paid_time_wage
  end
end