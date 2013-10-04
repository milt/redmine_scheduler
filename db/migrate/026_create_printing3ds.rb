class CreatePrinting3ds < ActiveRecord::Migration
  def change
    create_table :printing3ds do |t|
      t.references :user  # belongs-to relationship
      t.references :issue  # belongs-to relationship
      t.datetime :dropoff
      t.datetime :pickup
      t.string :patron_name
      t.string :patron_phone
      t.string :patron_dept
      t.string :patron_email
      t.string :affiliation
      t.string :payment_reference
      t.integer :budget_number
      t.string :budget_name
      t.string :budget_email
      t.string :budget_phone
      t.float :print_weight
      t.string :payment_type
      t.integer :total_cents, default: 0
      t.integer :deposit_cents, default: 0
      t.text :notes
      t.integer :quantity
      t.string :file_name
      t.string :material_type
    end
    add_index :printing3ds, :user_id
    add_index :printing3ds, :issue_id
  end
end
