require_dependency 'role'

module RedmineCopyProjects
  module Patches

    module ProjectsControllerPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          alias_method_chain :copy, :copy_projects
          skip_before_filter :require_admin, :only => [ :copy ]
        end
      end
    end

    module InstanceMethods
      def copy_with_copy_projects
        @issue_custom_fields = IssueCustomField.sorted.all
        @trackers = Tracker.sorted.all
        @source_project = Project.find(params[:id])
        if request.get?
          @project = Project.copy_from(@source_project)
          @project.identifier = Project.next_identifier if Setting.sequential_project_identifiers?
        else
          Mailer.with_deliveries(params[:notifications] == '1') do
            @project = Project.new
            @project.safe_attributes = params[:project]
            if validate_parent_id && @project.copy(@source_project, :only => params[:only])
              if params[:issues_author] && params[:issues_date]
                author = User.find(params[:issues_author])
                @project.issues.each do |issue|
                  issue.update_attributes(author: author, created_on: params[:issues_date])
                end
              end
              @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
              flash[:notice] = l(:notice_successful_create)
              redirect_to settings_project_path(@project)
            elsif !@project.new_record?
              # Project was created
              # But some objects were not copied due to validation failures
              # (eg. issues from disabled trackers)
              # TODO: inform about that
              redirect_to settings_project_path(@project)
            end
          end
        end
      rescue ActiveRecord::RecordNotFound
        # source_project not found
        render_404
      end
    end

  end
end

unless ProjectsController.included_modules.include?(RedmineCopyProjects::Patches::ProjectsControllerPatch)
  ProjectsController.send(:include, RedmineCopyProjects::Patches::ProjectsControllerPatch)
end