# Hooks to attach to the Redmine Issues.
class TracksIssueHook  < Redmine::Hook::ViewListener
  render_on :view_issues_show_description_bottom, :partial => 'tracks_settings/view_issues_show_description_bottom'
  
  # :params, :issue
  def controller_issues_edit_before_save(context = {})
    tracks_link = TracksLink.find_by_issue_id_and_user_id(context[:issue].id, User.current.id)
    if User.current.tracks_url.present? && tracks_link.present?
      toggle_todo(context, tracks_link, 'active') if context[:issue].closing?
      update_todo(tracks_link, context[:issue]) if User.current.tracks_time_sync
    end 
  end
  
  # :params, :issue, :time_entry, :journal
  def controller_issues_edit_after_save(context = {})
    tracks_link = TracksLink.find_by_issue_id_and_user_id(context[:issue].id, User.current.id)
    if User.current.tracks_url.present? && tracks_link.present? && context[:issue].changed?
      toggle_todo(context, tracks_link, 'completed') if context[:issue].closing?
      update_todo(tracks_link, context[:issue]) if User.current.tracks_time_sync
    end
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
  
  def toggle_todo(context, tracks_link, state)
    setup_todo
    begin
      todo = Todo.find(tracks_link.tracks_todo_id)
      todo.put(:toggle_check) if todo.state == state
    rescue Exception => e
      # silently ignore all messages and log them
      Rails.logger.error "Tracks connection error"
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
    end
  end
  
  def update_todo(tracks_link, issue)
    setup_todo
    begin
      todo = Todo.find(tracks_link.tracks_todo_id)
      todo.show_from = issue.start_date.strftime(User.current.tracks_time_format) if issue.start_date.present? && issue.start_date >= Date.today
      todo.due = issue.due_date.strftime(User.current.tracks_time_format) if issue.due_date.present? && issue.due_date >= Date.today

      todo.save

    rescue Exception => e
      # silently ignore all messages and log them
      Rails.logger.error "Tracks connection error"
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
