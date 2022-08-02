---
description: >-
  Creates a message that includes a link to a website, as well as a title,
  subtitle, photo and a button label.
---

# url

### <mark style="color:orange;">`url(params=Hash)`</mark>

### Platforms

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

### Usage

```ruby
@reply.url(
  {
    title: "Follow Kogno on Twitter",
    sub_title: "Get any update from our framework.",
    image: "https://pbs.twimg.com/profile_images/1533726469641338881/Q9dM6DpM_400x400.jpg",
    url: "https://twitter.com/kogno_framework",
    button: "Follow US"
  }
)    
```

### Params

| Name                                                                                                                       | Description                                                                                             |
| -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>title</code></mark><br><mark style="color:orange;"><code></code></mark>String</p>     | <p><strong>Required.</strong></p><p>URL Title</p>                                                       |
| <p><mark style="color:orange;"><code>sub_title</code></mark><br><mark style="color:orange;"><code></code></mark>String</p> | <p><strong>Optional.</strong><br><strong></strong>Brief description displayed below the title.</p>      |
| <p><mark style="color:orange;"><code>image</code></mark><br><mark style="color:orange;"><code></code></mark>String</p>     | <p><strong>Required.</strong><br>An image url</p>                                                       |
| <p><mark style="color:orange;"><code>url</code></mark><br><mark style="color:orange;"><code></code></mark>String</p>       | <p><strong>Required.</strong><br><strong></strong>An image url</p>                                      |
| <p><mark style="color:orange;"><code>button</code></mark><br><mark style="color:orange;"><code></code></mark>String</p>    | <p><strong>Optional.</strong><br><strong></strong>A button label. </p><p>Not available in WhatsApp.</p> |

In Messenger can be included two extra parameters: <mark style="color:orange;">`messenger_extensions`</mark> (boolean) and <mark style="color:orange;">`image_aspect_ratio`</mark> (:horizontal or :square). If they are present, the other platforms will just ignore them.
