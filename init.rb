require 'redmine'

Redmine::Plugin.register :redmine_franglish do
  name 'Redmine Franglish plugin'
  author 'Patrick Naubert/Michael RIchardson'
  description 'This is a plugin for Redmine to insert a bilingual profile which can be CLF2 constraints.'
  version '1.0.0'

  permission(:change_language, {:language_switcher => [:french, :english]}, :public => true)
  settings(:default => {
             'welcome_text_fr' => ''
           })

  menu :top_menu, :report_a_problem, '/projects/help-aide/issues/new', :caption => :text_report_a_problem
  menu :top_menu, :my_account, '/my/account', :caption => :label_my_account
end

require 'clf2/hooks/project_hooks'
require 'clf2/hooks/administration_settings_hooks'

# Patches to the Redmine core
require "dispatcher"
require 'clf2_application_controller_patch'
require 'clf2_projects_controller_patch'
require 'clf2_principal_patch'


Dispatcher.to_prepare :redmine_franglish_patches do
  begin
    require_dependency 'application'
  rescue LoadError
    require_dependency 'application_controller' # Rails 2.3
  end
  require_dependency 'principal'
  require_dependency 'user'
  require_dependency 'setting'

  unless ApplicationController.included_modules.include? Clf2::ApplicationController::Patch
    ApplicationController.send(:include, Clf2::ApplicationController::Patch)
  end
  ProjectsController.send(:include, Clf2::ProjectsController::Patch)
  Principal.send(:include, Clf2::Principal::Patch)
  User.send(:include, Clf2::Principal::Patch)
  Project.send(:include, Clf2::Patches::ProjectPatch)
  unless Setting.included_modules.include? Clf2::Patches::SettingPatch
    Setting.send(:include, Clf2::Patches::SettingPatch)
  end
  require_dependency 'settings_helper'
  unless SettingsHelper.included_modules.include? RedmineClf2::Patches::SettingsHelperPatch
    SettingsHelper.send(:include, RedmineClf2::Patches::SettingsHelperPatch)
  end
end

Redmine::MenuManager.map :top_menu do |menu|
  menu.delete(:help)
#  menu.push :english_help, "http://www.redmine.org/wiki/redmine/Guide", :last => true, :caption => :label_help, :if => Proc.new { ::I18n.locale == :en }
#  menu.push :french_help, "http://www.redmine.org/wiki/redmine/FrGuide", :last => true, :caption => :label_help, :if => Proc.new { ::I18n.locale == :fr }
  menu.push :help, '/projects/help-aide', :caption => :label_help
end
