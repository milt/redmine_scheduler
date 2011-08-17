class CreateBookings < ActiveRecord::Migration
  def self.up
    create_table :bookings do |t|
      t.column :timeslot_id, :integer
      t.column :name, :string
      t.column :phone, :string
      t.column :email, :string
      t.column :project_desc, :text
      t.column :apt_time, :datetime
      t.column :cancelled, :boolean
      
      t.timestamps
    end
  end

  def self.down
    drop_table :bookings
  end
end
