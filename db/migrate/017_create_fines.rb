class CreateFines < ActiveRecord::Migration
  def change
    create_table :fines do |t|
      t.string :patron_name
      t.string :patron_phone
      t.string :patron_email
      t.string :patron_jhed
      t.float :amount
      t.datetime :paid
      t.string :payment_method
      t.string :notes
      t.references :repair
      t.timestamps
    end
    add_index :fines, :repair_id
  end
end
