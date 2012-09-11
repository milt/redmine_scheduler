class AddCoachAndAuthorToBookings < ActiveRecord::Migration
  def self.up
    add_column :bookings, :coach_id, :integer
    add_column :bookings, :author_id, :integer
  end

  def self.down
    remove_column :bookings, :coach_id
    remove_column :bookings, :author_id
  end
end
