---
description: >-
  Sends a subscription request for recurring notifications in Messenger, which
  can be: daily, weekly and monthly.
---

# recurring\_notification\_request

### <mark style="color:orange;">`recurring_notification_request(request=Hash)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>false</td></tr><tr><td>Telegram</td><td>false</td></tr></tbody></table>

## Usage

### On-Demand

```ruby
user = User.where(platform: :messenger).first
user.notification.recurring_notification_request(
    {
        title: "Want to get daily notifications from us?",
        image_url: "https://previews.123rf.com/images/aquir/aquir1909/aquir190907932/129839413-bot%C3%B3n-de-suscripci%C3%B3n-suscr%C3%ADbete-letrero-rojo-redondeado-suscribir.jpg?fj=1",
        payload: :subscribe,
        frequency: :daily,
        reoptin: true
    }
)
user.notification.send
```

### Reply

```ruby
class MainContext < Conversation

  def actions

    payload :get_started do
    
      @reply.text "Welcome!"
      @reply.recurring_notification_request(
        {
          title: "Whould you like to receive weekly notifications from us?",
          image_url: "https://previews.123rf.com/images/aquir/aquir1909/aquir190907932/129839413-bot%C3%B3n-de-suscripci%C3%B3n-suscr%C3%ADbete-letrero-rojo-redondeado-suscribir.jpg?fj=1",
          payload: :subscribe,
          frequency: :weekly,
          reoptin: true
        }
      )
    end
    
  end
  
end
```

## <mark style="color:orange;">request</mark> param

| Name                                                                                                                                     | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| ---------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>title</code></mark><br><mark style="color:orange;"><code></code></mark><em>String</em></p>          | <p><strong>Required.</strong></p><p>The invitation/request title. The character limit is 65.</p>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| <p><mark style="color:orange;"><code>image_url</code></mark><br><mark style="color:orange;"><code></code></mark><em>String</em></p>      | <p><strong>Optional.</strong><br>The URL of the image to display.</p>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| <p><mark style="color:orange;"><code>payload</code></mark><br><mark style="color:orange;"><code></code></mark><em>String/Symbol</em></p> | <p><strong>Required.</strong><br>After perms granted/removed event, a <a href="../contexts/blocks/postback.md">postback action block</a> will be called if exists in the context.</p>                                                                                                                                                                                                                                                                                                                                                                                             |
| <p><mark style="color:orange;"><code>frequency</code></mark><br><mark style="color:orange;"><code></code></mark><em>Enum</em></p>        | <p><strong>Required.</strong><br><code>:daily</code>, <code>:weekly</code> or <code>:monthly</code>.</p>                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| <p><mark style="color:orange;"><code>reoptin</code></mark><br><mark style="color:orange;"><code></code></mark><em>Boolean</em></p>       | <p><strong>Optional.</strong><br>If <code>true</code>, sends a re opt-in template to the user after the set period for Recurring Notifications ends. <br>By default <code>false</code></p>                                                                                                                                                                                                                                                                                                                                                                                        |
| <p><mark style="color:orange;"><code>timezone</code></mark><br><mark style="color:orange;"><code></code></mark><em>String</em></p>       | <p><strong>Optional.</strong><br><strong>C</strong>an be set by Pages which determine when they can send Recurring Notifications after user opt-in. If Pages do not specify a timezone, the default timezone is UTC. Please see the <a href="https://scontent.fvlc4-1.fna.fbcdn.net/v/t39.8562-6/280309067_562342355463455_3557336671492726983_n.pdf?_nc_cat=104&#x26;ccb=1-7&#x26;_nc_sid=ae5e01&#x26;_nc_ohc=W4lxOXzmPHwAX9qE67d&#x26;_nc_ht=scontent.fvlc4-1.fna&#x26;oh=00_AT8JMeFzibi-Vd1bj1SGnkq_iFJ_QpCR4gQLNh1sIobRQg&#x26;oe=62A58452">list of valid time zones</a>.</p> |

{% hint style="success" %}
### Action Block `recurring_notification`

To capture the subscription and unsubscription events with this [action block](../contexts/blocks/recurring\_notification.md).
{% endhint %}

## Subscription Status

The user's subscription status can be verified by calling the <mark style="color:orange;">`messenger_recurring_notification_data()`</mark> method on the `User` model.

```ruby
user = User.where(platform: :messenger).first
user.messenger_recurring_notification_data
=> {:token=>"XXXXXXX", :frecuency=>"daily", :expires_at=>2022-11-21 18:06:31 UTC, :token_status=>"NOT_REFRESHED", :timezone=>"UTC", :status=>:active} 
```

## Sending Notifications

To send a notification using the recurring notification token, just call <mark style="color:orange;">`send_using_token()`</mark> method instead of <mark style="color:orange;">`send()`</mark>.

```ruby
user = u = User.where(platform: "messenger").first
user.notification.text "Hello World!"
user.notification.send_using_token()
```

{% hint style="info" %}
Learn more about Messenger Recurring Notification in the [official documentation](https://developers.facebook.com/docs/messenger-platform/send-messages/recurring-notifications).
{% endhint %}
