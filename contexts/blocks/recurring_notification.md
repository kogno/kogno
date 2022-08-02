---
description: >-
  This block will be executed when a user has granted or removed permissions to
  receive recurring notifications from Messenger.
---

# recurring\_notification

### <mark style="color:orange;">`recurring_notification(event=Enum(:granted, :removed), &block)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>false</td></tr><tr><td>Telegram</td><td>false</td></tr></tbody></table>

{% hint style="info" %}
## Recurring notification request

In order to make this event occurs, a notification request must be send to the user by calling the method [`recurring_notification_request()`](../../replies-notifications/recurring\_notification\_request.md)`.`
{% endhint %}

Read more about Messenger recurring notifications in the [official documentation](https://developers.facebook.com/docs/messenger-platform/send-messages/recurring-notifications/).

## Usage

```ruby
class MainContext < Conversation

  def actions
  
    recurring_notification :granted do |data|
      @reply.text "Thanks for subscribing to #{data[:frecuency]} notifications"    end

    recurring_notification :removed do |data|
      # Here you can handle the removed permission event
    end

    payload :get_started do
      @reply.text "Welcome!"
      @reply.notification.recurring_notification_request(
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

### Data param example

#### On permissions granted

```ruby
{
  token: "XXXXXXXXXXXXXXXXXXXXXX",
  frecuency: "WEEKLY",
  expires_at: "2023-03-21 12:27:09 UTC",
  token_status: "NOT_REFRESHED",
  timezone: "UTC",
  status: "active"
}
```

#### On permissions removed

```ruby
{
  token: "XXXXXXXXXXXXXXXXXXXXXX",
  frecuency: "WEEKLY",
  expires_at: "2023-03-21 12:27:09 UTC",
  token_status: "NOT_REFRESHED",
  timezone: null,
  status: "stopped"
}
```

{% hint style="info" %}
### User's Subscription Status

The user's subscription status can be verified by calling the <mark style="color:orange;">`messenger_recurring_notification_data()`</mark> method in the `User` model.
{% endhint %}

## Sending Notifications

To send a notification using the recurring notification token, just call <mark style="color:orange;">`send_using_token()`</mark> method instead of <mark style="color:orange;">`send()`</mark>.

```ruby
user = u = User.where(platform: "messenger").first
user.notification.text "Hello World!"
user.notification.send_using_token()
```
