class MakeTracksConnectionsMultiuser < ActiveRecord::Migration
  def self.up
    remove_column :issues, :tracks_todo_id
    remove_column :issues, :tracks_url
    create_table :tracks_links do |t|
      t.string :tracks_todo_id
      t.integer :issue_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :tracks_links
    add_column :issues, :tracks_todo_id, :integer, :null => true
    add_column :issues, :tracks_url, :string, :null => true
  end
end
