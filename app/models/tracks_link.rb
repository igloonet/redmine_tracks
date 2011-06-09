class TracksLink < ActiveRecord::Base
  def tracks_url
    setup_todo
    if User.current.tracks_url && get_context_id
      "#{Todo.site.scheme}://#{Todo.site.host}/#{Context.to_s.pluralize.underscore}/#{self.get_context_id}"
    else
      ''
    end
  end
  
  def get_context_id
    @context_id ||= Todo.find(self.tracks_todo_id).context_id
  rescue ActiveResource::ResourceNotFound, ActiveResource::ServerError
  end
  
  def setup_todo
    Todo.site = User.current.tracks_url
    Todo.site.user = User.current.tracks_user
    Todo.site.password = User.current.tracks_token 
  end
end
