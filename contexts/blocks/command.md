---
description: Catches a Telegram command, which  has been specified as an argument.
---

# command

{% hint style="info" %}
Read more about Telegram commands in the [official documentation](https://core.telegram.org/bots/#commands).
{% endhint %}

### <mark style="color:orange;">`command(name=String|Symbol, &block)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>false</td></tr><tr><td>WhatsApp</td><td>false</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

```ruby
class MainContext < Conversation

  def blocks
    
    command :start do
      @reply.text "Hello and welcome!"
    end
    
end
```

## Configuration

In order to be implemented in Kogno, the commands must be created first in Telegram through the [BotFather](https://t.me/BotFather) or well, by defining them in the configuration file [`config/platforms/telegram.rb`](../../getting-started/telegram-configuration.md) by modifying `config.telegram.commands` field.

```ruby
 config.telegram.commands = [
    {
      scope: :default,
      commands:{
        start: "Start chat",
        featured_products: "List featured products."
      }
    },
    {
      scope: :all_chat_administrators,
      commands:{
        update_products: "Update products from server.",
        purchase_count: "Sales today."
      }
    }

  ]
```

Available scopes are: `:default`, `:all_private_chats`, `:all_group_chats` and `:all_chat_administrators`. [Read more about Commands Scopes on Telegram](https://core.telegram.org/bots/api#botcommandscope).

### Command Line

Once configured, these changes must be sent to Telegram by running the following command in terminal.

#### Update all scopes

```bash
kogno telegram set_commands all
```

#### Update the scopes individually&#x20;

```
kogno telegram set_commands all_chat_administrators
```

{% hint style="success" %}
### Routing to Context

Each command can be routed to a specific context, learn how in [Routing Chapter](../routing.md#commands-telegram).
{% endhint %}
