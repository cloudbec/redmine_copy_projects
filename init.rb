Redmine::Plugin.register :redmine_copy_projects do
  name 'Redmine Copy Projects plugin'
  author 'Redmine CRM'
  description 'Allows user to copy project'
  version '0.0.1'
  url 'http://redminecrm.com'
  author_url 'mailto:support@redminecrm.com'

  permission :copy_projects, :projects => [:new, :create]

end

require 'redmine_copy_projects'