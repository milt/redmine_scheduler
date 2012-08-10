class CreateWages < ActiveRecord::Migration
  def self.up
    create_table :wages do |t|
      t.column :amount, :float
      t.column :user_id, :integer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :wages
  end
end
