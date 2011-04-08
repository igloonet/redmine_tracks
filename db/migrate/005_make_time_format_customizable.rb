class MakeTimeFormatCustomizable < ActiveRecord::Migration
  def self.up
    add_column :users, :tracks_time_format, :string, :null => true, :default => "%d/%m/%Y"
  end

  def self.down
    remove_column :users, :tracks_time_format
  end
end
