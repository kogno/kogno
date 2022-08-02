---
description: Creates a message with contact information.
---

# contact

### <mark style="color:orange;">`contact(params=Hash)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>false</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

### Usage

```ruby
if @user.platform == "telegram"

  @reply.contact(
    {
      first_name: "Martín",
      last_name: "Acuña Lledó",
      phone_number: "+1 (321) 800-5873"
    }
  )

elsif @user.platform == "whatsapp"

  @reply.contact(
    [
      {
        name: {
          formatted_name: "Martín Acuña Lledó",
          first_name: "Martín",
          last_name: "Acuña Lledó"
        },
        phones:[
          {
            phone: "+1 (321) 800-5873",
            type: "HOME"
          }
        ]
      }
    ]
  )

end
```

### Params

| Name                                                                                                                  | Description                                                                                                                                                                                                                                                                                                                       |
| --------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>params</code></mark><br><mark style="color:orange;"><code></code></mark>Hash</p> | <p><strong>Required.</strong></p><p>It varies depends on the platform. </p><p>Please check documentation on <a href="https://developers.facebook.com/docs/whatsapp/cloud-api/reference/messages#contacts-object">WhatsApp</a> and <a href="https://core.telegram.org/bots/api#sendcontact">Telegram</a> for more information.</p> |
