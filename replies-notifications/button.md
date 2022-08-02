---
description: A text followed by one or more buttons.
---

# button

### <mark style="color:orange;">`button(text=String, buttons=Array/Hash, params=Hash)`</mark>

## **Platforms**&#x20;

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th><th>Native Name</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td><td><code></code><a href="https://developers.facebook.com/docs/messenger-platform/reference/buttons/"><code>buttons</code></a><code></code></td></tr><tr><td>WhatsApp</td><td>true</td><td><a href="https://developers.facebook.com/docs/whatsapp/cloud-api/guides/send-messages#interactive-messages"><code>InteractiveMessages / button</code></a><code></code></td></tr><tr><td>Telegram</td><td>true</td><td><code></code><a href="https://core.telegram.org/bots/api#replykeyboardmarkup"><code>ReplyKeyboardMarkup</code></a><code></code></td></tr></tbody></table>

## Usage

### Reply

```ruby
@reply.button(
  "Hello, how can I help today?",
  [
    {
      title: "Create an account",
      payload: "profile/create_account"
    },
    {
      title: "Read TOS",
      payload: "read_tos"
    },
    {
      title: "Feature Product",
      payload: set_payload("products/view", { product_id: 10 })
    }
  ]
)
```

### On-Demand

```ruby
user.notification.button(
  "Hello, how can I help today?",
  [
    {
      title: "Create an account",
      payload: "profile/create_account"
    },
    {
      title: "Read TOS",
      payload: "read_tos"
    },
    {
      title: "Feature Product",
      payload: set_payload("products/view", { product_id: 10 })
    }
  ]
)
user.notification.send()
```

{% hint style="info" %}
In either case, the click event will be captured by a [postback](../contexts/blocks/postback.md) block (if declared) in the context defined in the payload route.
{% endhint %}

## Payload formats

### To the same context

```ruby
"read_tos"
```

### To a different context

```ruby
"profile/create_account"
```

### With params

```ruby
set_payload("products/view", { product_id: 10 })
```

## Arguments

| Name                                         | Description                                                                                                                                    |
| -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| <mark style="color:orange;">`text`</mark>    | <p><strong>Required.</strong></p><p>The text displayed above the buttons.</p>                                                                  |
| <mark style="color:orange;">`buttons`</mark> | <p><strong>Required.</strong><br><strong></strong>One or several buttons that can be payloads or links in some platforms<strong>.</strong></p> |
| <mark style="color:orange;">`params`</mark>  | <p><strong>Optional.</strong><br>Extra parameters that may vary between platforms.</p>                                                         |

### Extra params

Below are some unified or built-in parameters from this framework.

#### <mark style="color:orange;">`typed_postbacks`</mark>

Regardless of the value of `config.typed_postbacks` in the [main configuration](../getting-started/configuration.md), this feature can be enabled/disabled independently passing this parameter with true or false.

```ruby
@reply.button(
  "Hello, how are you today?",
  [
    {
      title: "Good",
      payload: "good_mood"
    },
    {
      title: "Bad",
      payload: "bad_mood"
    }
  ],
  { typed_postbacks: true }
)
```

#### <mark style="color:orange;">**`slice_replies`**</mark>

Only available in Telegram, it allows displaying a defined amount of buttons in rows.

```ruby
@reply.button(
  "Choose a number from 1 to 10",
  (1..10).map{|number|
    {
      title: "Number: #{number}",
      payload: set_payload(:number_response,{ number: number})
    }
  },
  { slice_replies: 3  }
)  
```

{% hint style="success" %}
For more information, read more about the expected params for each platform:

* [Messenger](https://developers.facebook.com/docs/messenger-platform/reference/buttons/)
* [WhatsApp](https://developers.facebook.com/docs/whatsapp/cloud-api/guides/send-messages#interactive-messages)
* [Telegram](https://core.telegram.org/bots/api#replykeyboardmarkup)
{% endhint %}
