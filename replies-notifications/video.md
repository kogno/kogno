---
description: Creates a message with a video provided via a url.
---

# video

### <mark style="color:orange;">`video(params=Hash)`</mark>

### **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

### Usage

```ruby
@reply.video({
  url: "https://kogno.io/video.mp4",
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

| Name                                                                                                                     | Description                                                                                                                                                                                                 |
| ------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>url</code></mark><br><mark style="color:orange;"><code></code></mark>String</p>     | <p><strong>Required.</strong></p><p>Video url</p>                                                                                                                                                           |
| <p><mark style="color:orange;"><code>caption</code></mark><br><mark style="color:orange;"><code></code></mark>String</p> | <p><strong>Optional:</strong> Telegram and WhatsApp<br>Short information about the video.<br>Not available in Messenger.</p>                                                                                |
| <p><mark style="color:orange;"><code>buttons</code></mark><br><mark style="color:orange;"><code></code></mark>Array</p>  | <p><strong>Optional.</strong><br><strong></strong><em>Array de botones, dependiendo de la</em> Array of buttons, depending on the platform they can be of different types, by default they are payload.</p> |

