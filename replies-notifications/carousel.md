---
description: Messenger Generic Templates Carousel.
---

# carousel

### <mark style="color:orange;">`carousel(elements=Array, quick_replies=Array, image_aspect_ratio=:horizontal|:square)`</mark>

### **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>false</td></tr><tr><td>Telegram</td><td>false</td></tr></tbody></table>

### Usage

```ruby
news = feed_entries("https://rss.nytimes.com/services/xml/rss/nyt/World.xml")

@reply.notification.carousel(
  news[0..9].map{|article|
    {
      title: article.title,
      image_url: article.image.to_s,
      subtitle: article.summary.to_s.truncate(50),
      default_action: {
        type: :web_url,
        url: article.url,
        webview_height_ratio: :tall,
        messenger_extensions: true
      },
      buttons: [
        {
          type: :web_url,
          url: article.url,
          title: "Read more",
          webview_height_ratio: :tall,
          messenger_extensions: true
        }
      ]
    }
  },
  [
    {
      title: "Read CNN",
      payload: "news/cnn_carousel"
    }
  ],
  :square
)
```

{% hint style="info" %}
For a complete list of template properties, see the [Generic Template reference](https://developers.facebook.com/docs/messenger-platform/reference/template/generic/) in Messenger Platform.
{% endhint %}

## Params

| Name                                                    | Description                                                                                                                                                |
| ------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <mark style="color:orange;">`elements`</mark>           | <p><strong>Required.</strong></p><p>Array with Messenger Generic Templates. There can be no more than 10 items.</p>                                        |
| <mark style="color:orange;">`quick_replies`</mark>      | <p><strong>Optional.</strong><br><strong></strong>Array of quick replies displayed bellow the carousel.</p>                                                |
| <mark style="color:orange;">`image_aspect_ratio`</mark> | <p><strong>Optional.</strong><br>Carousel images can be <code>:horizontal</code> or <code>:square</code>. </p><p>By default  <code>:horizontal</code>.</p> |
