---
description: >-
  This block will catch any attachment file like a document, audio, image,
  sticker or video.
---

# any\_attachment

### <mark style="color:orange;">`any_attachment(&block)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

Since each platform handles attachments differently, we recommend the use of `@user.platform` method to handle this separately, as in the following example:

```ruby
class MainContext < Conversation

  def blocks

    any_attachment do |attachments|
    
      if @user.platform == "messenger"
        #Handle attachments param for Messenger
      elsif @user.platform == "telegram"
        #Handle attachments param for Telegram
      elsif @user.platform == "whatsapp"
        #Handle attachments param for WhatsApp
      end
      
    end

  end
  
end
```
