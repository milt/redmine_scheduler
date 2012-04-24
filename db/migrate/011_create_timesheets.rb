class CreateTimesheets < ActiveRecord::Migration
  def self.up
    create_table :timesheets do |t|
      t.column :user_id, :integer
      t.column :pay_period, :datetime
      t.column :print_date, :datetime
      t.column :paid, :boolean
      t.column :notes, :text
      
      t.timestamps
    end
  end

  def self.down
    drop_table :timesheets
  end
end
