# encoding: UTF-8
require 'redmine'
require 'tracks_issue_hook'

Redmine::Plugin.register :redmine_tracks do
  name 'Redmine Tracks plugin'
  author 'Marek Hulán'
  description 'This is a plugin for tracks integration via tracks REST API'
  version '0.0.1'

  menu :account_menu, :tracks, { :controller => 'tracks_settings', :action => 'index' }, 
    :caption => 'Tracks', :if => Proc.new{ !User.current.kind_of?(AnonymousUser) }, :before => :logout
    
end
