---
description: Creates a message with an image provided via a url.
---

# image

### <mark style="color:orange;">`image(params=Hash)`</mark>

### **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

### Usage

```ruby
@reply.image({
  url: "https://pbs.twimg.com/profile_images/1533726469641338881/Q9dM6DpM_400x400.jpg",
  caption: "Kogno Framework",
  buttons: [
    {
      payload: :contact_us,
      title: "Contact US!"
    },
    {
      payload: :twitter,
      title: "Follow US!"
    }
  ]
})
```

### Params

| Name                                                                                                                              | Description                                                                                                                                                                 |
| --------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>url</code></mark><br><mark style="color:orange;"><code></code></mark>String</p>              | <p><strong>Required.</strong></p><p>Image URL</p>                                                                                                                           |
| <p><mark style="color:orange;"><code>caption</code></mark><br><mark style="color:orange;"><code></code></mark>String</p>          | <p><strong>Optional:</strong> Telegram and WhatsApp<br><strong>Required:</strong> Messenger.<br>Brief description of the image.</p>                                         |
| <p><mark style="color:orange;"><code>buttons</code></mark><br><mark style="color:orange;"><code></code></mark>Array</p>           | <p><strong>Optional.</strong><br><strong></strong>Array of buttons, depending on the platform they can be of different types, by default they are <code>payload</code>.</p> |
| <p><mark style="color:orange;"><code>image_aspect_ratio</code></mark><br><mark style="color:orange;"><code></code></mark>Enum</p> | <p><strong>Optional.</strong><br><strong></strong>Only available on Messenger.<br><code>:horizontal</code> (Default) or <code>:square</code></p>                            |
