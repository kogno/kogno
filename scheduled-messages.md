---
description: Schedule and send messages in the future.
---

# Scheduled Messages

### <mark style="color:orange;">`schedule(send_at=Time, tag=Symbol)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

### On Demand

```ruby
user = User.first
user.notification.text "You'll receive this after 1 minute"
user.notification.scheduled(Time.now + 1.minute)
```

#### Send bulk

```ruby
users = User.all
users.each do |user|
    user.notification.text "This is an important announcement"
    user.notification.template "main/announcement", {announcement_id: 1}
    user.notification.scheduled(Date.tomorrow.to_time)
end
```

### Reply

```ruby
@reply.text "This is a reminder" 
@reply.text "Take the cookies out of the oven"
@reply.scheduled(Time.now + 30.minutes)
```

## Params



| Name                                                                                                                            | Description                                                                                                    |
| ------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>send_at</code></mark><br><mark style="color:orange;"><code></code></mark><em>Time</em></p> | <p><strong>Required.</strong></p><p>The date and time when message(s) will be sent.</p>                        |
| <p><mark style="color:orange;"><code>tag</code></mark><br><mark style="color:orange;"><code></code></mark><em>Symbol</em></p>   | <p><strong>Optional.</strong><br><strong></strong>Scheduled message identification tag, can be any symbol.</p> |

## Daemon

To send scheduled messages, there is a process that must be running. It can be started as follows:

### In Background

```bash
kogno scheduled_messages start
```

### In Foreground

```
kogno scheduled_messages fg
```

### With the others processes from Kogno

```
kogno start
Kogno 1.0.0 server starting in production
Http: starting daemon..
Sequence: starting daemon..
Scheduled Messages: starting daemon..
```

## Deleting and Re-Scheduling

If the tag argument has been included in the creation of a scheduled message, as the example bellow:

```ruby
user = User.first
user.notification.text "This is a 24 hours reminder."
user.notification.scheduled(Time.now + 24.hours, :window_24h)
```

Then the following methods of the `User` model can be called:

### <mark style="color:orange;">`destroy_scheduled_messages(tag=Symbol)`</mark>

Deletes the scheduled message associated with the provided tag.

```ruby
@user.destroy_scheduled_messages(:window_24h)
```

### <mark style="color:orange;">`reschedule_message(tag=Symbol)`</mark>

Re-Schedule the messages associated with the provided tag.

```ruby
@user.reschedule_scheduled_message(:window_24h, Time.now + 23.hours + 55.minutes)
```

### <mark style="color:orange;">`scheduled_message?(tag=Symbol)`</mark>

Checks if there is a scheduled message associated with the provided tag.

```ruby
@user.scheduled_message?(:window_24h)
```

