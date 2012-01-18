class CreateSkillcats < ActiveRecord::Migration
  def self.up
    create_table :skillcats do |t|
      t.column :name, :string
      t.column :descr, :text
    end
  end

  def self.down
    drop_table :skillcats
  end
end
