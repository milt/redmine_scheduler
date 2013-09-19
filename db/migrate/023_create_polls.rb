class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.string :question
      t.integer :yes
      t.integer :no
    end
  end
end
