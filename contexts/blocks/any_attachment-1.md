---
description: >-
  It going to be executed if the incoming message contains at least one number
  (integer or float) and  it will return as a parameter an array with the
  numbers found.
---

# any\_number

### <mark style="color:orange;">`any_number(&block)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

```ruby
class MainContext < Conversation

  def blocks

    any_number do |numbers|
      @reply.text "You've sent these numers: #{numbers.join(" ,")}"
    end

  end
  
end
```
