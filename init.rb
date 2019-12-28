require 'redmine'
require 'mail_handler_patch_ignore'
Redmine::Plugin.register :helpdesk_required_cf_ignore do
  name 'Helpdesk ignore required custom field for e-mail'
  author 'Sergey Melnikov'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/SimSmolin/helpdesk_required_cf_ignore.git'
  author_url 'https://github.com/SimSmolin'
end
