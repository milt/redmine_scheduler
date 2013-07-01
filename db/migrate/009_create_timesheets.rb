class CreateTimesheets < ActiveRecord::Migration
  def self.up
    create_table :timesheets do |t|
      t.column :user_id, :integer
      t.column :weekof, :date
      t.column :print_date, :datetime
      t.column :submitted, :datetime
      t.column :approved, :datetime
      t.column :notes, :text
      t.column :approve_time_wage, :float
      
      t.timestamps
    end
  end

  def self.down
    drop_table :timesheets
  end
end
