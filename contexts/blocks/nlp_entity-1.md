---
description: >-
  If it was called, this block will always be executed at the end of the
  matching process, even if another block was executed previously.
---

# after\_all

### <mark style="color:orange;">`before_anything(&block)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

```ruby
class MainContext < Conversation

  def actions

    intent :greeting do 
      @reply.text "Hello, how can I help you?"
    end
    
    after_all do
       logger.info "This block will be executed on every incoming message or event"
    end

  end

end
```

{% hint style="warning" %}
## Execution exception

It will not be executed if [`delegate_to()`](../#delegate\_to-route-string-args-hash) or [`halt()`](./#halt) methods were called in a block executed previously.
{% endhint %}
