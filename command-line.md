# Command Line

## New Project

Create a new project in the provided directory.

```bash
kogno new your_project_name
```

## Create table

Creates the database tables needed for the framework.

{% hint style="danger" %}
This command must be executed after configuring the database in `config/database.yml`.
{% endhint %}

```
kogno install
```

## Processes

Kogno runs a total of 3 processes, which can be started all together or separately:

| Daemon               | Description                                                                                                                       |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `http`               | Web server that receives the events and messages from the configured platforms, in addition to the requests in the `web/` folder. |
| `sequences`          | Process that executes the queue from the [sequences](contexts/sequences.md).                                                      |
| `scheduled_messages` | Process that executes the [scheduled messages](scheduled-messages.md) queue.                                                      |

### Manage All Together

#### Start all in Background

```
kogno start
```

```
Kogno 1.0.0 server starting in development
Http: starting daemon..
Sequence: starting daemon..
Scheduled Messages: starting daemon..
```

Other options are: `kogno stop`, `kogno restart` and `kogno status`

### HTTP Server

#### Run in Background

```
kogno http start
```

Other options are: `kogno http stop`, `kogno http restart` and `kogno http status`

#### Run in Foreground

```
kogno http fg
```

### Sequences

#### Run in Background

```
kogno sequences start
```

Other options are: `kogno sequences stop`, `kogno sequences restart` and `kogno sequences status`

#### Run in Foreground

```
kogno sequences fg
```

### Scheduled Messages Daemon

#### Run in Background

```
kogno scheduled_messages start
```

Other options are: `kogno scheduled_messages stop`, `kogno scheduled_messages restart` and `kogno scheduled_messages status`.

#### Run in Foreground

```
kogno scheduled_messages fg
```

{% hint style="info" %}
The daemons can run either in background or foreground for environments of development or production. To configure in environment, [see configuration chapter](getting-started/configuration.md).
{% endhint %}

## Console

The `console` command starts the console that lets you interact with your Kogno application from the command line.&#x20;

```bash
kogno console
```

{% hint style="success" %}
You can also use the alias "c" to load the console: `kogno c`.
{% endhint %}

### Usage example

```ruby
kogno c
Loading development environment (Kogno 1.0.1)
2.7.0 :001 > user = User.first
 => #<User id: 1, psid: "600....> 
2.7.0 :002 > puts user.first_name
Martín
 => nil 
```

{% hint style="info" %}
Within the console, you can run the `reload!` to restart the console quickly.
{% endhint %}

## Runner

`runner` runs Ruby code in terminal.&#x20;

```
kogno runner "some ruby code"
```

#### Example

```
kogno runner "puts User.first.first_name"
  User Load (0.5ms)  SELECT `users`.* FROM `users` ORDER BY `users`.`id` ASC LIMIT 1
Martín
```

## Messenger

### Persistent Menu

Activates the [persistent menu](https://developers.facebook.com/docs/messenger-platform/send-messages/persistent-menu/) in Messenger Platform.

```
kogno messenger menu on
```

{% hint style="info" %}
Before run this command you should configure `config.messenger.persistent_menu` in [`config/platforms/messenger.rb`](getting-started/messenger-configuration.md)``
{% endhint %}

#### To Remove Persistent Menu

```
kogno messenger menu off
```

### Get Started Button

Activates and set the [get started button payload](https://developers.facebook.com/docs/messenger-platform/discovery/welcome-screen/#set\_postback) of Messenger.

```
kogno messenger get_started on
```

{% hint style="info" %}
You can change the payload editing `config.messenger.welcome_screen_payload` in the Messenger configuration file [`config/platforms/messenger.rb`](getting-started/messenger-configuration.md)``
{% endhint %}

#### To Deactivate

```
kogno get_started off
```

### Setting the Greeting Text <a href="#set_greeting" id="set_greeting"></a>

Activates [greeting text on the welcome screen](https://developers.facebook.com/docs/messenger-platform/discovery/welcome-screen/#set\_greeting) on Messenger.

```
kogno messenger greeting on
```

{% hint style="info" %}
Before run this command you should configure `config.messenger.greeting` in [`config/platforms/messenger.rb`](getting-started/messenger-configuration.md)``
{% endhint %}

#### To Deactivate

```
kogno messenger greeting off
```

### Whitelisted Domains

Update [whitelisted domains](https://developers.facebook.com/docs/messenger-platform/reference/messenger-profile-api/domain-whitelisting/) in Messenger Platform.

```
kogno messenger update_whitelisted_domains
```

{% hint style="info" %}
Before run this command, configure `config.messenger.whitelisted_domains` in [`config/platforms/messenger.rb`](getting-started/messenger-configuration.md)``
{% endhint %}

### Ice Breakers <a href="#set_greeting" id="set_greeting"></a>

Activates Messenger Platform [ice breakers](https://developers.facebook.com/docs/messenger-platform/instagram/features/ice-breakers).

```
kogno messenger ice_breakers on
```

{% hint style="info" %}
Before run this command, please configure `config.messenger.ice_breakers` in [`config/platforms/messenger.rb`](getting-started/messenger-configuration.md)``
{% endhint %}

#### To Deactivate

```
kogno messenger ice_breakers off
```

## Telegram

### Webhook

Set and activate a url and receive incoming updates via a webhook.

```
kogno telegram webhook on
```

{% hint style="info" %}
Before running this command, please set `config.telegram.webhook_https_server` in [`config/platforms/telegram.rb`](getting-started/telegram-configuration.md) file.
{% endhint %}

#### To Stop Receiving Webhooks

```
kogno telegram webhook off
```

### Commands

Set and activate commands for every [command scope available in Telegram](https://core.telegram.org/bots/api#botcommandscope).

#### Set/Update all Scopes

```
kogno telegram set_commands all
```

#### Available Scopes

`default`, `all_private_chats`, `all_group_chats`, `all_chat_administrators` and `all`

#### To Deactivate Commands

```
kogno telegram delete_commands all
```
