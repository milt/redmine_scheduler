class AddWageToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :wage_id, :integer
  end

  def self.down
    remove_column :users, :wage_id
  end
end
