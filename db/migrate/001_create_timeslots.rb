class CreateTimeslots < ActiveRecord::Migration
  def self.up
    create_table :timeslots do |t|
      t.column :issue_id, :integer
      t.column :slot_time, :integer
      t.column :booking_id, :integer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :timeslots
  end
end
