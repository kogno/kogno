Kogno::Application.configure do |config|

  config.app_name = "Kogno"

  config.environment = :development

  config.http_port = 3000

  # Internacionalization (I18n)
  config.available_locales = [:en]
  config.default_locale = :en

  # Default context for any arrived message or event
  config.routes.default = :main

  config.sequences.time_elapsed_after_last_usage = 900 # 15 minutes

  config.store_log_in_database = false

  config.typed_postbacks = false

  config.error_notifier.slack = {
    enable: false,
    webhook: "<YOUR SLACK WEBHOOOK HERE>"
  }  

end

