# annoying naming convention, class name must match filename
# class AddShiftIDToLCRatings < ActiveRecord::Migration
class AddShiftToRatings < ActiveRecord::Migration
  def self.up
    add_column :lc_ratings, :issue_id, :integer
  end

  def self.down
    remove_column :lc_ratings, :issue_id
  end
end
