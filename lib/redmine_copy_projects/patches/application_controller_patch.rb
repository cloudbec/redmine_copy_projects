require_dependency 'role'

module RedmineCopyProjects
  module Patches

    module ApplicationControllerPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          alias_method_chain :require_admin, :copy_projects
        end
      end
    end

    module InstanceMethods
      def require_admin_with_copy_projects
        unless action_name == :show && controller_name == :projects && User.current.allowed_to(:copy_projects, nil)
          require_admin_without_copy_projects
        end
      end
    end

  end
end

unless ApplicationController.included_modules.include?(RedmineCopyProjects::Patches::ApplicationControllerPatch)
  ApplicationController.send(:include, RedmineCopyProjects::Patches::ApplicationControllerPatch)
end