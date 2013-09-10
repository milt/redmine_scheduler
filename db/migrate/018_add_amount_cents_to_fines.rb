class AddAmountCentsToFines < ActiveRecord::Migration
  def self.up
    remove_column :fines, :amount
    add_column :fines, :amount_cents, :integer
  end

  def self.down
    remove_column :fines, :amount_cents
    add_column :fines, :amount, :float
  end
end
