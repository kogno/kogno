ActiveSupport::Deprecation.silenced = true
require 'action_view'
require 'tilt'

$LOAD_PATH.push("#{Kogno::Application.project_path}/lib")

Kogno::Application.load_core
Kogno::Application.load_locales
Kogno::Application.load_app
