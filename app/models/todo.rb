class Todo < ActiveResource::Base
  def full_url
    "#{self.class.site.scheme}://#{self.class.site.host}/#{Context.to_s.pluralize.underscore}/#{self.context_id}"
  end 
end