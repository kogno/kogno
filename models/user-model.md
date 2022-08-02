---
description: >-
  It is one of the models that is predefined in a new project and is associated
  with the users table in the database.
---

# User model

In the conversation flow <mark style="color:blue;">`@user`</mark> can be called, which is an instance of this model for the user who is chatting.

## Location

{% code title="bot/models/user.rb" %}
```ruby
class User < ActiveRecord::Base

end
```
{% endcode %}

## `users` table schema

| `id`                     | Secuencial record ID.                                                                  |
| ------------------------ | -------------------------------------------------------------------------------------- |
| `psid`                   | The user identification on each platform.                                              |
| `platform`               | The platform through which the user is chatting.                                       |
| `psid_from_post_comment` | The user's ID who has commented on a post on the Fan Page associated with the project. |
| `page_id`                | Facebook Page's ID                                                                     |
| `name`                   | User's name.                                                                           |
| `first_name`             | User's first name.                                                                     |
| `last_name`              | User's last name.                                                                      |
| `timezone`               | User's timezone.                                                                       |
| `locale`                 | User's locale.                                                                         |
| `last_usage_at`          | Stores the last time when a message or event was received from the user.               |
| `context`                | The current context of the conversation with the user.                                 |
| `context_params`         | Stores the parameters from the current context of the conversation with the user.      |
| `session_vars`           | Stores the user's session vars.                                                        |
| `last_message_read`      | Boolean that indicates if the last message sent was read by the user.                  |
| `created_at`             | Date and time of record creation.                                                      |
| `updated_at`             | Date and time of the record's last update.                                             |

{% hint style="success" %}
### New User Creation

When an incoming message or event arrives, in the most of the cases it will be associated to a person(user).&#x20;

Through this model, Kogno will automatically create a record with the user's information in the table `users` in the database.&#x20;
{% endhint %}

## Common Methods and Attributes.

### <mark style="color:orange;">`first_time?()`</mark>

This method returns true if the user has been created current session.

#### Usage

```ruby
if @user.first_time?
    @reply.text t(:welcome)
else
    @reply.text t(:hello)
end
```

### <mark style="color:orange;">`platform`</mark>

This attribute returns the user's platform. For example: `"messenger"`, `"telegram"` or `"whatsapp"`.

#### Usage

```ruby
case @user.platform
  when "messenger"
    @reply.text "You're in Messenger"
  when "whatsapp"
    @reply.text "You're in WhatsApp"
  when "telegram"
    @reply.text "You're in Telegram"
end
```

### <mark style="color:orange;">`context`</mark>

Returns the current context of the conversation with the user.

#### Usage

```ruby
@user.context
```

### <mark style="color:orange;">`exit_context()`</mark>

Exit the user from the current context of the conversation.

#### Usage

```ruby
@user.exit_context
```

### <mark style="color:orange;">`reschedule_message(tag=Symbol, send_at=Time)`</mark>

Re-Schedule the messages associated with the provided tag.

#### Usage

```ruby
@user.reschedule_scheduled_message(:window_24h, Time.now + 23.hours + 55.minutes)
```

### <mark style="color:orange;">`scheduled_message?(tag=Symbol)`</mark>

Returns true if there is a scheduled message associated with the provided tag.

#### Usage

```ruby
@user.scheduled_message?(:window_24h)
```

### <mark style="color:orange;">`destroy_scheduled_messages(tag=Symbol)`</mark>

Deletes the scheduled message associated with the provided tag.

#### Usage

```ruby
@user.destroy_scheduled_messages(:window_24h)
```

### <mark style="color:orange;">`messenger_recurring_notification_data()`</mark>

Returns the user's subscription status for Messenger Recurring Notifications

#### Usage

```ruby
user = User.where(platform: :messenger).first
user.messenger_recurring_notification_data
=> {:token=>"XXXXXXX", :frecuency=>"daily", :expires_at=>2022-11-21 18:06:31 UTC, :token_status=>"NOT_REFRESHED", :timezone=>"UTC", :status=>:active} 
```

### <mark style="color:orange;">`messenger_recurring_notification?()`</mark>

Returns true if the subscription to Messenger Recurring Notifications is active.

#### Usage

```ruby
user = User.where(platform: :messenger).first
if user.subscribed_to_messenger_recurring_notification?
    puts "active"
else
    puts "unactive"
end
```

### <mark style="color:orange;">`vars`</mark>

This attribute allows saving and retrieving any data within the conversation flow.

#### Saving data

```ruby
@user.vars[:contact_information] = {
    email: "martin@kogno.io",
    phone: "‭+34 654 022 112‬"
}
```

#### Retrieving data

```ruby
if @user.vars[:contact_information].nil?
    @reply.text "Your email: #{@user.vars[:contact_information][:email]}"
end    
```

#### Deleting data

```ruby
@user.vars[:contact_information] = nil
```

{% hint style="info" %}
Para usar este attributo fuera del flujo de la conversación se necesita llamar a los metodos get\_session\_vars() y save\_session\_vars()

```ruby
user = User.first
user.get_session_vars()
user.vars[:contact_information] = {
    email: "martin@kogno.io",
    phone: "‭+34 654 022 112‬"
}
user.save_session_vars()
```
{% endhint %}

### <mark style="color:orange;">`set_locale(locale=Symbol)`</mark>

Set user locale

#### Usage

```ruby
@user.set_locale(:es)
```

## Customization Example

Suppose we need to ask the user to leave us their email and we would like to save that information.&#x20;

To do this we could do the following:

### Adding email field in users table.

```sql
alter table users add email varchar(60)
```

### Editing User model

In the User model we will create the methods that we consider necessary to carry out this operation: in this case we will create one to save the mail and another to verify that it exists.

```ruby
class User < ActiveRecord::Base

  def save_email(email)
    self.email = email
    self.save
  end

  def has_email?
    self.email.nil?
  end
  
end
```

### Testing

We can test this on the console by running `kogno c` in the terminal

```bash
2.6.3 :001 > user = User.first
  User Load (0.6ms)  SELECT `users`.* FROM `users` WHERE `users`.`psid` = '111112222333333' LIMIT 1
 => #<User id: 1, psid: "111112222333333", page_id: "1111111111111111".... 
 2.6.3 :002 > user.has_email?
 => false
 2.6.3 :003 > user.save_email("martin@kogno.io")
  (0.2ms)  BEGIN
  User Update (6.8ms)  UPDATE `users` SET `users`.`email` = 'martin@kogno.io"' WHERE `users`.`id` = 1
  (4.5ms)  COMMIT
 => true
 2.6.3 :004 > user.has_email?
 => true
   
```
