---
description: Allows the creation of messages from WhatApp Templates.
---

# whatsapp\_template

### <mark style="color:orange;">`whatsapp_template(name=String, components=Array, language=String)`</mark>

{% hint style="success" %}
### Create a template

In order to create a WhatsApp Template, [read this guide](https://developers.facebook.com/docs/whatsapp/message-templates/creation/).
{% endhint %}

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>false</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>false</td></tr></tbody></table>

## Usage

```ruby
@reply.whatsapp_template("hello_world")
```

### On Demand

```ruby
user = User.first
user.notification.whatsapp_template(
  "sample_issue_resolution",
  [
    {
      type: :body,
      parameters: [
        {
          type: :text,
          text: "Martín"
        }
      ]
    }
  ] 
)
user.send
```

## Params

| Name                                                                                                                                | Description                                                                                                                                                                                                                                                    |
| ----------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>name</code></mark><br><mark style="color:orange;"><code></code></mark><em>String</em></p>      | <p><strong>Required.</strong></p><p>Name of the template.</p>                                                                                                                                                                                                  |
| <p><mark style="color:orange;"><code>components</code></mark><br><mark style="color:orange;"><code></code></mark><em>Array</em></p> | <p><strong>Optional.</strong><br><strong></strong>Array of <code>components</code> objects containing the parameters of the message. <a href="https://developers.facebook.com/docs/whatsapp/cloud-api/reference/messages#components-object">Read more</a>.</p> |
| <p><mark style="color:orange;"><code>language</code></mark><br><mark style="color:orange;"><code></code></mark><em>String</em></p>  | <p><strong>Optional</strong>.<br>Contains a <code>language</code> object. Specifies the language the template may be rendered in. By default: <em>"en_US"</em>.</p>                                                                                            |

{% hint style="info" %}
Learn more about WhatsApp Templates in the [official documentation](https://developers.facebook.com/docs/whatsapp/cloud-api/reference/messages#template-object).
{% endhint %}
