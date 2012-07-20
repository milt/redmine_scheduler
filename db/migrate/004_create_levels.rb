class CreateLevels < ActiveRecord::Migration
  def self.up
    create_table :levels do |t|
      t.integer :skill_id
      t.integer :user_id
      t.integer :rating

      t.timestamps
    end
  end

  def self.down
    drop_table :levels
  end
end
