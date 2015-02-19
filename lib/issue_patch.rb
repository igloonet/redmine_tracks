require_dependency 'issue'

module IssuePatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      has_many :tracks_links
    end
  end

  module InstanceMethods; end
end

unless Issue.included_modules.include?(IssuePatch)
  Issue.send(:include, IssuePatch)
end
