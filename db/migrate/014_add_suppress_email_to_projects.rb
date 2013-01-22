class AddSuppressEmailToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :suppress_email, :boolean, :default => false
  end

  def self.down
    remove_column :projects, :suppress_email
  end
end
