---
description: >-
  If it's called in the current context of the conversation, it will always be
  executed, at the beginning of the block matching process.
---

# before\_anything

{% hint style="info" %}
This is one of the exceptional blocks that when executed does not stop the matching process for subsequent blocks.
{% endhint %}

### <mark style="color:orange;">`before_anything(&block)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

In the example below, `before_anything` and [`any_text`](any\_attachment-2.md) will always be executed on arrival of a text message:

```ruby
class MainContext < Conversation

  def blocks

    before_anything do
       logger.debug "This block is executed Before any other block in this context"
    end
    
    any_text do |text|
       @reply.text "You've sent me '#{text}'"
    end

  end

end
```
