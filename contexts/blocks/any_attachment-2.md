# any\_text

This block will be executed with any text message and will return as parameter the text message.

### <mark style="color:orange;">`any_text(&block)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

```ruby
class MainContext < Conversation

  def blocks

    any_text do |text|
      @reply.text "You wrote: '#{text}'"
    end

  end
  
end
```
