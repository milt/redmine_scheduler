class AddAmountCentsToWages < ActiveRecord::Migration
  def self.up
    remove_column :wages, :amount
    add_column :wages, :amount_cents, :integer
  end

  def self.down
    remove_column :wages, :amount_cents
    add_column :wages, :amount, :float
  end
end
