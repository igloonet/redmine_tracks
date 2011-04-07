class AddTracksUrlToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :tracks_url, :string, :null => true
  end

  def self.down
    remove_column :issues, :tracks_url
  end
end
