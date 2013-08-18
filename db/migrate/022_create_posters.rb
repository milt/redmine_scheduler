class CreatePosters < ActiveRecord::Migration
  def change
    create_table :posters do |t|
      t.references :user
      t.references :issue
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
      t.float :doc_width
      t.float :doc_height
      t.float :print_width
      t.float :print_height
      t.float :border
      t.string :payment_type
      t.integer :total_cents
      t.integer :deposit_cents
      t.text :notes
      t.integer :quantity
    end
    add_index :posters, :user_id
    add_index :posters, :issue_id
  end
end
