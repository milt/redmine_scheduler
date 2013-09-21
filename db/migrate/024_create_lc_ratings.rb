class CreateLcRatings < ActiveRecord::Migration

  def self.up
    create_table :lc_ratings do |t|
      t.column :rated_user_id, :integer
      t.column :rating, :integer
      t.column :rater_user_id, :integer
      t.column :comment, :string
    end
  end

  def self.down
  	drop_table :lc_ratings
  end
end
