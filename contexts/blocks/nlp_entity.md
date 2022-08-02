---
description: >-
  This block will be executed when the chatbot has been added or removed from a
  group or channel from Telegram.
---

# membership

### <mark style="color:orange;">`membership(event=Enum(:new, :drop), &block)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>false</td></tr><tr><td>WhatsApp</td><td>false</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

```ruby
class MainContext < Conversation

  def blocks

    membership :new do |chat|
      @reply.text "You've added me to #{chat[:title]}"
      @reply_group.text "Hello, I'm glad to be part of this #{chat[:type]}"
    end

    membership :drop do |chat|
      @reply.text "You've removed me from #{chat[:title]}"
      logger.debug_json chat, :red
    end

  end
  
end
```

In this block <mark style="color:blue;">`@reply_group`</mark> can be called, this is a notification instance for the group or channel. <mark style="color:blue;">`@reply`</mark> as always responds to the user, in this case the admin of the  group/channel  who added or removed the chatbot.
