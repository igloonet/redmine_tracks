class AddTracksToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :tracks_url, :string, :null => true
    add_column :users, :tracks_user, :string, :null => true
    add_column :users, :tracks_token, :string, :null => true
  end

  def self.down
    remove_column :users, :tracks_url
    remove_column :users, :tracks_user
    remove_column :users, :tracks_token
  end
end
