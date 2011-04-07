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
    
    todo = Todo.new(:context_id => params[:context_id], :project_id => params[:project_id],
          :description => @issue.to_s, :notes => notes, 
          :due => @issue.due_date.try(:strftime, "%d/%m/%Y"),
          :show_from => @issue.start_date.try(:strftime, "%d/%m/%Y"))
    
    if @result = todo.save
      @result &= @issue.update_attributes :tracks_url => todo.full_url, :tracks_todo_id => todo.id
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
    Context.site = User.current.tracks_url
    Context.site.user = User.current.tracks_user
    Context.site.password = User.current.tracks_token
    TracksProject.site = User.current.tracks_url
    TracksProject.site.user = User.current.tracks_user
    TracksProject.site.password = User.current.tracks_token
    Todo.site = User.current.tracks_url
    Todo.site.user = User.current.tracks_user
    Todo.site.password = User.current.tracks_token
  end
end
