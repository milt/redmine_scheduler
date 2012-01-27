class CreateWages < ActiveRecord::Migration
  def self.up
    create_table :wages do |t|
      t.column :amount, :float
    end
  end

  def self.down
    drop_table :wages
  end
end
