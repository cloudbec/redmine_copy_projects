require_dependency 'role'

module RedmineCopyProjects
  module Patches

    module RolePatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          alias_method_chain :allowed_to?, :copy_projects
        end
      end
    end

    module InstanceMethods
      def allowed_to_with_copy_projects?(action)
        if [:add_subprojects].include? action
          allowed_to_without_copy_projects?(:copy_projects)
        else
          allowed_to_without_copy_projects?(action)
        end
      end
    end

  end
end

unless Role.included_modules.include?(RedmineCopyProjects::Patches::RolePatch)
  Role.send(:include, RedmineCopyProjects::Patches::RolePatch)
end