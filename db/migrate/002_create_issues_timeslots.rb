class CreateIssuesTimeslots < ActiveRecord::Migration
  def self.up
    create_table :issues_timeslots, :id => false do |t|
      t.integer :issue_id
      t.integer :timeslot_id
    end
  end

  def self.down
    drop_table :issues_timeslots
  end
end
