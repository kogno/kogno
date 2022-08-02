---
description: Allows the creation of messages from Messenger Generic Templates.
---

# messenger\_generic\_template

### <mark style="color:orange;">`messenger_generic_template(elements=Hash|Array, image_aspect_ration=Enum, quick_replies=Array)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>false</td></tr><tr><td>Telegram</td><td>false</td></tr></tbody></table>

## Usage

```ruby
@reply.messenger_generic_template(
  {
    title: "The Title",
    subtitle: "This is the subtitle",
    image_url: "https://pbs.twimg.com/profile_images/1533726469641338881/Q9dM6DpM_400x400.jpg",          
    default_action: {
      type: :web_url,
      url: "https://kogno.io",
      :webview_height_ratio => :tall,
      messenger_extensions: true
    },
    buttons: [
      {
        type: :web_url,
        url: "https://kogno.io",
        title: "Call to Action ➡️",
        webview_height_ratio: :tall,
        messenger_extensions: true
      }
    ]
  },
  :square,
  [
    {
      title: "Button bellow",
      payload: "some_context/some_payload"
    }
  ]
)
```

## Params

| Name                                                                                                                                       | Description                                                                                                                                                                                                                                                                   |
| ------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>elements</code></mark><br><mark style="color:orange;"><code></code></mark><em>Hash|Array</em></p>     | <p><strong>Required.</strong></p><p>Can be Hash or an Array of Hashes.  View the full structure of <code>elements</code> in  <a href="https://developers.facebook.com/docs/messenger-platform/reference/templates/generic#elements">Messenger Platform</a> documentation.</p> |
| <p><mark style="color:orange;"><code>image_aspect_ratio</code></mark><br><mark style="color:orange;"><code></code></mark><em>Enum</em></p> | <p><strong>Optional.</strong><br><strong></strong>The aspect ratio used to render images specified by <code>element.image_url</code>. Must be <code>horizontal</code> (1.91:1) or <code>square</code> (1:1). Defaults to <code>horizontal</code>.</p>                         |
| <p><mark style="color:orange;"><code>quick_replies</code></mark><br><mark style="color:orange;"><code></code></mark><em>Array</em></p>     | <p><strong>Optional</strong>.<br>Array of buttons that appear below the carousel.</p>                                                                                                                                                                                         |

{% hint style="info" %}
Learn more about Messenger Generic Templates in the [official documentation](https://developers.facebook.com/docs/messenger-platform/reference/templates/generic).
{% endhint %}
