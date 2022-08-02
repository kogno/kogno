---
description: >-
  This block will be executed if the regular expression provided matches with a
  pattern against the incoming message.
---

# regular\_expression

### <mark style="color:orange;">`regular_expression(rg=Regexp|String, &block)`</mark>

This block returns as a parameter an array of all matched items.

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

```ruby
class MainContext < Conversation

  def blocks

    regular_expression /([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)/ do |emails|
      @rsp.text("This is your email #{emails.first}")
    end
    
    regular_expression /(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14})/ do |credit_cards|
      @rsp.text("The credit card provided is #{credit_cards.first}")
    end
    
  end
  
end
```
