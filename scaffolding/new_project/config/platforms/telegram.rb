Kogno::Application.configure do |config|

  config.telegram.bot_name = "<Your Bot Name in Telegram>"
  
  config.telegram.api_url = "https://api.telegram.org"

  config.telegram.token = "<Your token here>"

  # After configure the following three fiels you can run 'kogno telegram webhook on' in order to receive updates from Telegram
  config.telegram.webhook_https_server = "https://yourdomain.com"
  config.telegram.webhook_route = "/webhook_telegram"
  config.telegram.webhook_drop_pending_updates = true # If true, every time you run 'kogno telegram webhook on' this will drop pending updates from Telegram.


  # Default routes for special updates in Telegram
  config.routes.inline_query = :main
  config.routes.chat_activity = :main

  #Commands

  # You can create different commands for several scopes.
  # Valid scopes: default, all_private_chats, all_group_chats and all_chat_administrators
  # After configure this part, you can run 'kogno telegram set_commands default|all_private_chats|all_group_chats|all_chat_administrators|all'
  config.telegram.commands = [
    {
      scope: :default,
      commands:{
        start: "Here, the command's description"
      }
    },
    # {
    #   scope: :all_private_chats,
    #   commands:{
    #     start: "Here, the command's description",
    #     command2: "Here, the command's description"
    #   }
    # }
  ]

  # Route a command to a spesific context
  config.routes.commands = {
    start: :main
  }

end