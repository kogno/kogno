# Messenger Configuration

{% hint style="warning" %}
Before configuring this section, you must have an App created in Meta and a Facebook Page. See the instructions [here](https://developers.facebook.com/docs/messenger-platform/getting-started/app-setup).
{% endhint %}

The configuration file for Messenger is located at `config/platforms/messenger.rb`

```ruby
Kogno::Application.configure do |config|
  
  config.messenger.graph_url = "https://graph.facebook.com/v2.6/me"

  config.messenger.pages = {
    "YOUR_FANPAGE_ID" => {
      name: "YOUR_FANPAGE_NAME",
      token: "YOUR_ACCESS_TOKEN"
    },
    # "YOUR_2ND_FANPAGE_ID" => {
    #   name: "YOUR_2ND_FANPAGE_NAME",
    #   token: "YOUR_2ND_ACCESS_TOKEN"
    # }
  }

  config.messenger.webhook_route = "/webhook_messenger"
  config.messenger.webhook_verify_token = "<YOUR_VERIFY_TOKEN>"
  
  config.routes.post_comment = :main

  config.routes.recurring_notification = :main

  config.messenger.whitelisted_domains = [
    "kogno.io"
  ]

  config.messenger.persistent_menu =  [
    {
      locale: :default,
      composer_input_disabled: false,
      call_to_actions: [
        {
          title: "Title",
          type: :postback,
          payload: "your_context/a_payload_in_the_context"
        },
        {
          title: "Title2",
          type: :postback,
          payload: "your_payload"
        }
      ]
    }
  ]

  config.messenger.welcome_screen_payload = "GET_STARTED"

  config.messenger.greeting = [
    {
      locale: :default,
      text: "Hello word."
    }
  ]

  config.messenger.ice_breakers = [
    {
      question: "Question 1?",
      payload: "context/payload"
    },
    {
      question: "Question 2",
      payload: "payload_two"
    }
  ]  

end
```

### Field Description

| Configuration                             | Description                                                                                                                                                                                                                                                                                                                                                      |
| ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `config.messenger.graph_url`              | Facebook Graph Url                                                                                                                                                                                                                                                                                                                                               |
| `config.messenger.pages`                  | One or more Facebook Pages can be configured and run under the same project.                                                                                                                                                                                                                                                                                     |
| `config.messenger.webhook_route`          | <p>The CallBack URL path where the Messenger Platform will send notifications. <br><mark style="color:orange;"><code></code></mark>Read the more about this <a href="https://developers.facebook.com/docs/messenger-platform/webhooks">here</a>.</p>                                                                                                             |
| `config.messenger.webhook_verify_token`   | Messenger Platform token for [verification request](https://developers.facebook.com/docs/messenger-platform/webhooks#verification-requests).                                                                                                                                                                                                                     |
| `config.routes.post_comment`              | Configure the default context which will handle a message from a Post Commend. [Read more](https://developers.facebook.com/docs/messenger-platform/discovery/private-replies/)                                                                                                                                                                                   |
|  `config.messenger.persistent_menu`       | <p><a href="https://developers.facebook.com/docs/messenger-platform/send-messages/persistent-menu">The persistent menu</a> allows you to have an always-on user interface element inside Messenger conversations. <br></p><p>To activate/deactivate it run:</p><p> <code>kogno messenger menu on|off</code></p>                                                  |
| `config.messenger.welcome_screen_payload` | <p>The default postback payload for  the <a href="https://developers.facebook.com/docs/messenger-platform/discovery/welcome-screen/">Get Started button</a>. <br><br>To activate/deactivate it run<br><code>kogno messenger get_started on|off</code></p>                                                                                                        |
| `config.messenger.greeting`               | <p><a href="https://developers.facebook.com/docs/messenger-platform/reference/messenger-profile-api/greeting/">The greeting property</a> of your bot's Messenger profile allows you to specify the greeting message people will see on the welcome screen of your bot. <br><br>To activate/deactivate it run<br><code>kogno messenger greeting on|off</code></p> |
| `config.messenger.whitelisted_domains`    | <p>Messenger <a href="https://developers.facebook.com/docs/messenger-platform/reference/messenger-profile-api/domain-whitelisting/">whitelisted domains</a>. </p><p>After modifying this you should run this command <code>kogno messenger update_whitelisted_domains</code></p>                                                                                 |
| `config.messenger.ice_breakers`           | <p><a href="https://developers.facebook.com/docs/messenger-platform/send-messages">Ice Breakers</a> provide a way for users to start a conversation with a business with a list of frequently asked questions.</p><p><br>To activate/deactivate it run<br><code>kogno messenger ice_breakers on|off</code></p>                                                   |
