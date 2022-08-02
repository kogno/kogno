---
description: Simple text message.
---

# text

### <mark style="color:orange;">`text(text=String, params=Hash)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

### Reply

```ruby
@reply.text "Hello World!"
```

### On-Demand

```ruby
user.notification.text "Hello World"
user.notification.send()
```

## Params

Each platform has different parameters, in Kogno we have unified `preview_url` available for Telegram and WhatsApp.

```ruby
@reply.text "Kogno docs are awesome http://docs.kogno.io", {preview_url: true}
```

### Check extra params in each platform

* [WhatsApp](https://developers.facebook.com/docs/whatsapp/on-premises/reference/messages#text-object)
* [Messenger](https://developers.facebook.com/docs/messenger-platform/reference/send-api/#message)
* [Telegram](https://core.telegram.org/bots/api#sendmessage)****
