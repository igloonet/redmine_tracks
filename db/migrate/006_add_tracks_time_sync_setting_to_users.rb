class AddTracksTimeSyncSettingToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :tracks_time_sync, :boolean, :null => true, :default => false
  end

  def self.down
    remove_column :users, :tracks_time_sync
  end
end
