class AddSlotDatetimeToTimeslots < ActiveRecord::Migration
  def self.up
    add_column :timeslots, :slot_datetime, :datetime
  end

  def self.down
    remove_column :timeslots, :slot_datetime
  end
end
