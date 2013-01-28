class AddDigestToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :digest, :boolean, :default => true
  end

  def self.down
    remove_column :users, :digest
  end
end
