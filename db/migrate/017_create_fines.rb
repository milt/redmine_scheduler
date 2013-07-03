class CreateFines < ActiveRecord::Migration
  def change
    create_table :fines do |t|
      t.string :patron_name
      t.string :patron_phone
      t.string :patron_email
      t.string :patron_jhed
      t.references :repair
      t.timestamps
    end
    add_index :fines, :repair_id
  end
end
