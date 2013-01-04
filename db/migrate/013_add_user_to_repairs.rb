class AddUserToRepairs < ActiveRecord::Migration
  def self.up
    add_column :repairs, :user_id, :integer
  end

  def self.down
    remove_column :repairs, :user_id
  end
end
