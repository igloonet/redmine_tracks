RedmineApp::Application.routes.draw do
  match 'tracks_settings', :controller => 'tracks_settings', :action => 'index'
end
