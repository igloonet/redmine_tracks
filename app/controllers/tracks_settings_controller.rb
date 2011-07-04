class TracksSettingsController < ApplicationController
  before_filter :authorize
  unloadable
  def index
  end

  def update_tracks
    User.current.attributes = params[:user]
    if User.current.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :controller => 'tracks_settings', :action => 'index'
    else
      flash.now[:error] = l(:error_updating_tracks)
      render :controller => 'tracks_settings', :action => 'index'
    end
  end
  
  before_filter :setup_resources, :only => [:new_connection, :create_connection]
  
  def new_connection
    @issue = Issue.find(params[:id])
    @contexts = Context.find :all
    @projects = TracksProject.find :all
  rescue ActiveResource::UnauthorizedAccess
    @error = t('tracks_invalid_credentials', :credentials => @template.link_to(t('tracks_here'), :controller => 'tracks_settings'))
  end
  
  def create_connection
    @issue = Issue.find(params[:id])
    notes = @issue.description.size >= 1_000 ? @issue.description[0..999] + '...' : @issue.description
    notes = url_for(:controller => 'issues', :action => 'show', :id => @issue, :only_path => false) + "\n\n" + notes
    description = @issue.to_s
    description = description.size > 100 ? description[0..99] : description.to_s

    todo = Todo.new(:context_id => params[:context_id], :project_id => params[:project_id],
          :description => description.tr("'\"", ''), :notes => notes)
          
    todo.show_from = @issue.start_date.strftime(User.current.tracks_time_format) if @issue.start_date.present? && @issue.start_date >= Date.today
    todo.due = @issue.due_date.strftime(User.current.tracks_time_format) if @issue.due_date.present? && @issue.due_date >= Date.today
    
    begin
      @result = todo.save
    rescue ActiveResource::ServerError
      # show from makes problems some time, nilify it then
      Rails.logger.fatal 'trying to nilify show from and saving again'
      todo.show_from = nil
      @result = todo.save
    end
 
    if @result
      tracks_link = TracksLink.new(:tracks_todo_id => todo.id, :user_id => User.current.id, :issue_id => @issue.id)
      @result &= tracks_link.save
      # rollback unless connection between issue and todo was saved
      todo.destroy unless @result
    end
    
  rescue ActiveResource::ServerError
    @result = false
    # another possible errors that could be catched 
    # 404 - bad url of any resource, this should be seen only when there is a problem in code
    # 422 - unprocessable entity means that there are some values missing I guess
  end

  protected
  def authorize
    redirect_to :controller => 'account', :action => 'login' and return false \
      if User.current.kind_of?(AnonymousUser)
  end
  
  def setup_resources
    [Context, TracksProject, Todo].each do |resource|
      resource.site = User.current.tracks_url
      resource.site.user = User.current.tracks_user
      resource.site.password = User.current.tracks_token
    end
  end
end
