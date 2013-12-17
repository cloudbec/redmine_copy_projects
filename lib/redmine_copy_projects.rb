ActionDispatch::Reloader.to_prepare do
  require_dependency 'redmine_copy_projects/patches/role_patch'
  require_dependency 'redmine_copy_projects/patches/projects_controller_patch'
end
