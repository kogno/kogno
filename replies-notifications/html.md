---
description: This method creates a message in HTML format.
---

# html

### <mark style="color:orange;">`html(code=String, reply_markup=Hash, extra_params=Hash)`</mark>

## Platforms

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>false</td></tr><tr><td>WhatsApp</td><td>false</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

### HTML Only

```ruby
@reply.html("<b>bold</b>, <strong>bold</strong> <i>italic</i>, <em>italic</em><u>underline</u>, <ins>underline</ins>")
```

### HTML with replies below&#x20;

```ruby
@reply.html(
  "<b> Here the HTML with some quick_replies </b>",
  {
    quick_reply: [
      {
        payload: :option_1,
        title: "Option 1!"
      },
      {
        url: "https://twitter.com/kogno_framework",
        title: "Follow US!"
      }
    ]
  }
)
```

### From `.rhtml` template

```ruby
  code = html_template("main/demo1")
  @reply.html(code)
```

The template <mark style="color:blue;">"main/demo1"</mark> is located in `bot/action_templates/main/demo1.rhtml` file.

```ruby
<% 7.times do %>
  <b>Hello</b> <i>World</i>
<% end
```

Read more about `html_template` method [here](../global-methods.md#html\_template).

### Params

| Name                                                                                                                        | Description                                                                                                                                                                                                                                                                                                                                             |
| --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>code</code></mark><br><mark style="color:orange;"><code></code></mark>String</p>       | <p><strong>Required.</strong></p><p>The HTML code, 4096 characters max. <br>View the full html tags supported by Telegram <a href="https://core.telegram.org/bots/api#html-style">here</a>.</p>                                                                                                                                                         |
| <p><mark style="color:orange;"><code>reply_markup</code></mark><br><mark style="color:orange;"><code></code></mark>Hash</p> | <p><strong>Optional.</strong><br><strong></strong>Hash with one element  that can be:</p><p><code>:quick_reply</code> => <a href="https://core.telegram.org/bots/api#inlinekeyboardmarkup">inlinekeyboardmarkup</a></p><p><code>:button</code> <em>=></em> <a href="https://core.telegram.org/bots/api#replykeyboardmarkup">replykeyboardmarkup</a></p> |
| <p><mark style="color:orange;"><code>extra_params</code></mark><br><mark style="color:orange;"><code></code></mark>Hash</p> | <p><strong>Optional.</strong><br><strong></strong>Hash with more params, view the <a href="https://core.telegram.org/bots/api#sendmessage">full list from Telegram</a>.</p>                                                                                                                                                                             |
