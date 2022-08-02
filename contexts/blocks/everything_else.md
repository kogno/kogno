---
description: >-
  It will be executed as long as none of the declared blocks in the current
  context have been executed. In other words, If the match doesn't occurs.
---

# everything\_else

### <mark style="color:orange;">`everything_else(&block)`</mark>

{% hint style="info" %}
This method is used to handle and eventually send a reply to a message that the chatbot couldn't understand.
{% endhint %}

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

```ruby
class MainContext < Conversation

  def actions
  
    intent "greeting" do 
      @reply.text "Hello!"
    end
    
    intent "thanks" do 
      @reply.text "You're welcome"
    end
    
    intent "bye" do
      @text.text "Good bye!"
    end
    
    everything_else do    
      @reply.text "I don't understand what you say"    
    end
    
  end
  
end
```
