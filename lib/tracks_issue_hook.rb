# Hooks to attach to the Redmine Issues.
class TracksIssueHook  < Redmine::Hook::ViewListener
  render_on :view_issues_show_description_bottom, :partial => 'tracks_settings/view_issues_show_description_bottom'
  
  # :params, :issue
  def controller_issues_edit_before_save(context = {})
    toggle_todo(context, 'active') if User.current.tracks_url.present? && context[:issue].tracks_todo_id.present? && context[:issue].closing? 
  end
  
  # :params, :issue, :time_entry, :journal
  def controller_issues_edit_after_save(context = {})
    toggle_todo(context, 'completed') if User.current.tracks_url.present? && context[:issue].tracks_todo_id.present? && context[:issue].changed? && context[:issue].closing?
  end
  
  protected
  
  def setup_todo
    TracksProject.site = User.current.tracks_url
    TracksProject.site.user = User.current.tracks_user
    TracksProject.site.password = User.current.tracks_token
    Context.site = User.current.tracks_url
    Context.site.user = User.current.tracks_user
    Context.site.password = User.current.tracks_token
    Todo.site = User.current.tracks_url
    Todo.site.user = User.current.tracks_user
    Todo.site.password = User.current.tracks_token
  end
  
  def toggle_todo(context, state)
    setup_todo
    begin
      todo = Todo.find(context[:issue].tracks_todo_id)
      todo.put(:toggle_check) if todo.state == state
    rescue Exception => e
      # silently ignore all messages and log them
      Rails.logger.error "Tracks connection error"
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
