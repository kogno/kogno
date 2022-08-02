# Global Methods

## <mark style="color:orange;">`set_payload(payload=String, params=Hash)`</mark>

Creates a [payload with parameters](contexts/blocks/postback.md#reading-params).

### Usage

```ruby
set_payload "products/show", {product_id: 5, category: "Clothes"}
```

This payload with its parameters will be received by a `postback` action block in the products context. Read about [postback block](contexts/blocks/postback.md#postback-params).

{% hint style="success" %}
The payload in Telegram is called [`callback_data`](https://core.telegram.org/bots/api#inlinekeyboardbutton) and it only supports 64 characters. In Kogno we managed to increase that limit to much more, so you should not worry about that limit anymore.
{% endhint %}

## <mark style="color:orange;">`html_template(route=String, params=Hash)`</mark>

Render a template with `.rhtml` extension from the `bot/templates/context_name/` directory.

### Usage

```ruby
html_template "main/demo1", { title: "This is the title" }
```

The template `"main/demo1"` will be located in `bot/templates/main/demo1.rhtml`.

```ruby
<%= title %>
<% 7.times do %>
  <b>Hello</b> <i>World</i>
<% end %>
```

