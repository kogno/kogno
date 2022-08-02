---
description: >-
  If it's defined, this action block will be executed if the chat was opened
  through a link that contains a deep-link query string parameter.
---

# deep\_link

The query string parameters are <mark style="color:purple;">`ref`</mark> for Messenger and <mark style="color:purple;">`start`</mark> for Telegram.

{% hint style="info" %}
To learn more, please read the official documentation from [Messenger](https://developers.facebook.com/docs/messenger-platform/reference/webhook-events/messaging\_referrals/#m-me) and [Telegram](https://core.telegram.org/bots#deep-linking).
{% endhint %}

### <mark style="color:orange;">`deep_link(&block)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>false</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Example Links

#### Messenger: [`https://m.me/kogno.io?ref=test`](https://m.me/kogno.io?ref=test1)``

#### Telegram: [`https://t.me/KognoBot?start=test`](https://t.me/KognoBot?start=test1)``

## Usage

```ruby
class MainContext < Conversation

  def blocks

    deep_link do |value|
      @reply.text("You just clicked on a link with the value #{value}!")
    end

  end
  
end
```

## &#x20;<mark style="color:orange;">`value`</mark> param

This param contains the value passed in the query string, for the example links above, the value is <mark style="color:blue;">`"test"`</mark>

{% hint style="success" %}
## Routing to Context

A deep-link can be handled by other context different than the [default context](../#default-context-maincontext), simply by passing the name of an existing context as a part of the parameter value:

**Messenger:** <mark style="color:purple;">`?ref=context_name_some_value`</mark>

**Telegram:** <mark style="color:purple;">`?start=context_name_some_value`</mark>

<mark style="color:purple;">``</mark>

Read more about this in [Context Routing chapter](../routing.md#deep-links).
{% endhint %}

