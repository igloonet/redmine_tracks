RedmineApp::Application.routes.draw do
  match 'tracks_settings', :controller => 'tracks_settings', :action => 'index'
  match 'tracks_settings/update_tracks', :controller => 'tracks_settings', :action => 'update_tracks'
end
