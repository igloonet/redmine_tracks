# Hooks to attach to the Redmine Issues.
class TracksIssueHook  < Redmine::Hook::ViewListener
  render_on :view_issues_show_description_bottom, :partial => 'tracks_settings/view_issues_show_description_bottom'
  
  # :params, :issue
  def controller_issues_edit_before_save(context = {})
    tracks_link = TracksLink.find_by_issue_id_and_user_id(context[:issue].id, User.current.id)
    if User.current.tracks_url.present? && tracks_link.present?
      toggle_todo(context, tracks_link, 'active') if context[:issue].closing?
      update_todo(tracks_link) if User.current.tracks_time_sync
    end 
  end
  
  # :params, :issue, :time_entry, :journal
  def controller_issues_edit_after_save(context = {})
    tracks_link = TracksLink.find_by_issue_id_and_user_id(context[:issue].id, User.current.id)
    if User.current.tracks_url.present? && tracks_link.present? && context[:issue].changed?
      toggle_todo(context, tracks_link, 'completed') if context[:issue].closing?
      update_todo(tracks_link) if User.current.tracks_time_sync
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
  
  def update_todo(tracks_link)
    setup_todo
    begin
      todo = Todo.find(tracks_link.tracks_todo_id)
      todo.show_from = tracks_link.issue.start_date.strftime(User.current.tracks_time_format) if tracks_link.issue.start_date.present? && tracks_link.issue.start_date >= Date.today
      todo.due = tracks_link.issue.due_date.strftime(User.current.tracks_time_format) if tracks_link.issue.due_date.present? && tracks_link.issue.due_date >= Date.today

      todo.save

    rescue Exception => e
      # silently ignore all messages and log them
      Rails.logger.error "Tracks connection error"
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
