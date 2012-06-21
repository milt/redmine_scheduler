class AddHometownToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :hometown, :string
  end

  def self.down
    remove_column :users, :hometown
  end
end