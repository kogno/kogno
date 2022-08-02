---
description: This block will be executed if the message is one of the defined keywords.
---

# keyword

### <mark style="color:orange;">`keyword(String|Array, &block)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

```ruby
class MainContext < Conversation

  def blocks

    keyword ["stop","close","quit"] do
      @reply.text "I'll stop responding you until you write the keyword 'start'"
    end
    
    keyword "start" do
      @rsp.text("Great!")
      @reply.text "Let's chat again! 😃"
    end
    
  end
  
end
```
