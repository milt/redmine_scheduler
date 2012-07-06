class ChangePaidOnTimesheets < ActiveRecord::Migration
  def self.up
    remove_column :timesheets, :paid
    add_column :timesheets, :paid, :datetime
    add_column :timesheets, :submitted, :datetime
  end

  def self.down
    add_column :timesheets, :paid, :boolean
    remove_column :timesheets, :submitted
    remove_column :timesheets, :paid
  end
end