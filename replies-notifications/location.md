---
description: A message with a location.
---

# location

Crea un mensaje de un mapa con un lugar específico.

### <mark style="color:orange;">`contact(params=Hash)`</mark>

### **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>false</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

### Usage

```ruby
@reply.location({
  name: "Home Sweet Home",
  longitude: 3.077330,
  latitude: 39.890020
})
```

### Params

| Name                                                                                                                  | Description                                                                                                                                                                                                                                                                                                                  |
| --------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>params</code></mark><br><mark style="color:orange;"><code></code></mark>Hash</p> | <p><strong>Required.</strong></p><p>It varies depends on the platform, please check documentation for <a href="https://developers.facebook.com/docs/whatsapp/cloud-api/reference/messages#location-object">WhatsApp</a> and <a href="https://core.telegram.org/bots/api#sendlocation">Telegram</a> for more information.</p> |
