class CreateRepairs < ActiveRecord::Migration
  def self.up
    create_table :repairs do |t|
      t.column :issue_id, :integer
      t.column :item_number, :integer
      t.column :item_desc, :string
      t.column :problem_desc, :text
      t.column :patron_name, :string
      t.column :patron_phone, :string
      t.column :patron_email, :string
      t.column :patron_jhed, :string
      t.column :notes, :text
      
      t.timestamps
    end
  end

  def self.down
    drop_table :repairs
  end
end