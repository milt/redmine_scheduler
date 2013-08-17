class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.string :message
      t.references :user
    end
    add_index :reminders, :user_id
  end
end
