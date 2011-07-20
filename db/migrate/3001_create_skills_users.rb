class CreateSkillsUsers < ActiveRecord::Migration
  def self.up
    create_table :skills_users, :id => false do |t|
      t.references :skill
      t.references :user
    end
    add_index(:skills_users, [:skill_id, :user_id], :unique => true)
  end

  def self.down
    drop_table :skills_users
    remove_index :skills_users
  end
end