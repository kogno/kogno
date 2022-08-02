# Configuration

Kongo's main configuration file is located at `config/application.rb`

```ruby
Kogno::Application.configure do |config|

  config.app_name = "Kogno"

  config.environment = :development

  config.http_port = 3000

  config.available_locales = [:en]
  config.default_locale = :en

  config.routes.default = :main

  config.sequences.time_elapsed_after_last_usage = 900 # 15 minutes

  config.store_log_in_database = false

  config.typed_postbacks = false

  config.error_notifier.slack = {
    enable: false,
    webhook: "<YOUR SLACK WEBHOOOK HERE>"
  }  

end
```

### Field Description

| Field                                                  | Description                                                                                                                                                                                                                                                                                                                                       |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `config.app_name`                                      | The project's name.                                                                                                                                                                                                                                                                                                                               |
| `config.environment`                                   | <p>Defines the environment: <code>development</code> or <code>production</code>. </p><p>In <code>development</code> mode you will see more logs and isn't necessary to restart when the code is modified.</p>                                                                                                                                     |
| `config.http_port`                                     | The port where the web server runs.                                                                                                                                                                                                                                                                                                               |
| `config.available_locales`                             | The available locales of the project.                                                                                                                                                                                                                                                                                                             |
| `config.default_locale`                                | The default language in case [Internationalization](../internationalization.md) is implemented.                                                                                                                                                                                                                                                   |
| `config.routes.default`                                | The general context, which will handle a message when the conversation with a user has no defined context.                                                                                                                                                                                                                                        |
| `config.delayed_actions.time_elapsed_after_last_usage` | The minimum waiting time in seconds to send the next message of a sequence to an user, after he has sent the last message to the conversation. Read more in the [Sequences chapter](../contexts/sequences.md).                                                                                                                                    |
| `config.store_log_in_database`                         | If <mark style="color:green;">`true`</mark>, it will save incoming messages, events and replies to the `kogno_chat_logs` database table.                                                                                                                                                                                                          |
| `config.typed_postbacks`                               | If <mark style="color:green;">`true`</mark>, options on [`buttons`](../replies-notifications/button.md) or [`quick_replies`](../replies-notifications/quick\_reply.md) will be matched against the next message received. Read about this functionality [here](../contexts/blocks/postback.md#typed-postbacks).                                   |
| `config.error_notifier.slack`                          | <p>If <code>enable</code> field is <mark style="color:green;"><code>true</code></mark> and a Slack <code>webhook</code> url is configured, the framework will send any error to the channel associated in Slack.  <br><a href="https://slack.com/help/articles/115005265063-Incoming-webhooks-for-Slack">Read the documentation in Slack</a>.</p> |



