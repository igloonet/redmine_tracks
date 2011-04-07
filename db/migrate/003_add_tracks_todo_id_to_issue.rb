class AddTracksTodoIdToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :tracks_todo_id, :integer, :null => true
  end

  def self.down
    remove_column :issues, :tracks_todo_id
  end
end
