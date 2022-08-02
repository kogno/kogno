---
description: This method creates a message in Makrdown format.
---

# markdown

### <mark style="color:orange;">`markdown(syntax=String, reply_markup=Hash, extra_params=Hash)`</mark>

### Platforms

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>false</td></tr><tr><td>WhatsApp</td><td>false</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

{% hint style="info" %}
View the full Markdown styles supported by Telegram [here](https://core.telegram.org/bots/api#markdownv2-style).
{% endhint %}

### Usage

#### Markdown only

```ruby
@reply.markdown("*bold text* _italic text_ __underline__ ~strikethrough~")
```

#### Markdown with buttons

```ruby
@reply.markdown(
  "*bold text* _italic text_ __underline__ ~strikethrough~",
  {
    button: [
      {
        payload: :option_1,
        title: "Option 1!"
      }
    ]
  }
)
```

### Params

| Name                                                                                                                        | Description                                                                                                                                                                                                                                                                                                                                             |
| --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>syntax</code></mark><br><mark style="color:orange;"><code></code></mark>String</p>     | <p><strong>Required.</strong></p><p><em>The Markdown syntax with</em> 4096 characters max.<br>View the styles supported <a href="https://core.telegram.org/bots/api#markdownv2-style">here</a>.</p>                                                                                                                                                     |
| <p><mark style="color:orange;"><code>reply_markup</code></mark><br><mark style="color:orange;"><code></code></mark>Hash</p> | <p><strong>Optional.</strong><br><strong></strong>Hash with one element  that can be:</p><p><code>:quick_reply</code> => <a href="https://core.telegram.org/bots/api#inlinekeyboardmarkup">inlinekeyboardmarkup</a></p><p><code>:button</code> <em>=></em> <a href="https://core.telegram.org/bots/api#replykeyboardmarkup">replykeyboardmarkup</a></p> |
| <p><mark style="color:orange;"><code>extra_params</code></mark><br><mark style="color:orange;"><code></code></mark>Hash</p> | <p><strong>Optional.</strong><br><strong></strong>Hash with more params, view the <a href="https://core.telegram.org/bots/api#sendmessage">full list from Telegram</a>.</p>                                                                                                                                                                             |
