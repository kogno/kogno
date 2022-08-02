# Telegram Configuration

{% hint style="warning" %}
In Order to configure this section you must have created a bot following the [Telegram instructions](https://core.telegram.org/bots#3-how-do-i-create-a-bot).
{% endhint %}

&#x20;The Telegram configuration file is located at `config/platforms/telegram.rb`

```ruby
Kogno::Application.configure do |config|

  config.telegram.bot_name = "<Your Bot Name in Telegram>"
  
  config.telegram.api_url = "https://api.telegram.org"

  config.telegram.token = "<Your token here>"

  config.telegram.webhook_https_server = "https://yourdomain.com"
  config.telegram.webhook_route = "/webhook_telegram"
  config.telegram.webhook_drop_pending_updates = true

  config.routes.inline_query = :main
  config.routes.chat_activity = :main

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

  config.routes.commands = {
    start: :main
  }

end
```

### Field Description

| Configuration                                   | Description                                                                                                                                                                                                                                                                          |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| config.telegram.bot\_name                       | Your bot's name, normally ended with the string _"bot"_. Example: `KognoBot`                                                                                                                                                                                                         |
| config.telegram.api\_url                        | The telegram api url.                                                                                                                                                                                                                                                                |
| config.telegram.token                           | The [BotFather](https://t.me/BotFather) will provide you with one after you have created a bot on Telegram.                                                                                                                                                                          |
| config.telegram.webhook\_https\_server          | Your public https url for you project.                                                                                                                                                                                                                                               |
| config.telegram.webhook\_route                  | The CallBack url path where Telegram will send the notifications.                                                                                                                                                                                                                    |
| config.telegram.webhook\_drop\_pending\_updates | Pass <mark style="color:green;">`true`</mark> to drop all pending updates after run `kogno telegram webhook start`.                                                                                                                                                                  |
| config.routes.inline\_query                     | Configure the default context which will handle incoming [inline query](https://core.telegram.org/bots/api#inline-mode).                                                                                                                                                             |
| config.routes.chat\_activity                    | <p>Configure the default context which will handle <a href="../contexts/blocks/nlp_entity.md">changes on member status</a> in a group or channel.</p><p>Read more in <a href="https://core.telegram.org/bots/api#chatmemberupdated">Telegram</a>.</p>                                |
| config.telegram.commands                        | <p>Configure the bot command in the following scopes: <code>default</code>, <code>all_private_chats</code>, <code>all_group_chats</code> and <code>all_chat_administrators</code>.<br><br>Run <code>kogno telegram set_commands all</code> to update all the bot command scopes.</p> |
| config.routes.commands                          | <p>Configure the context which will handle each command. </p><p>If isn't defined the context will be the defined in <code>config.routes.message</code> in the <a href="configuration.md">project's main configuration</a>.</p>                                                       |



## Webhook

{% hint style="success" %}
In order to start to receive incoming updates via an outgoing webhook, you must have configured `config.telegram.webhook_https_server` and `config.telegram.webhook_route`.
{% endhint %}

### Start to receiving incoming updates

```
kogno telegram webhook start
```

### To stop

```
kogno telegram webhook stop
```
