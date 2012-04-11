class AddManagerToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :manager_id, :integer
  end

  def self.down
    remove_column :users, :manager_id
  end
end
