---
description: >-
  A list with multiple options, the click event on one of them, sends a payload
  that can be captured by a postback action block.
---

# list

### <mark style="color:orange;">`list(params=Hash, header=Hash, footer=Hash)`</mark>

### **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>false</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>false</td></tr></tbody></table>

## Usage

```ruby
@reply.list(
  {
    text: "Which pet do you like the most?",
    button: "Answer",
    sections:[
      {
        title: "Dogs",
        rows:[
          {
            title: "Labrador Retriever",
            payload: set_payload("pet_preferences", {pet: "dog", breed: "labrador_retriever"}),
          },
          {
            title: "German Shepherd",
            payload: set_payload("pet_preferences", {pet: "dog", breed: "german_shepherd"}),
          },
          {
            title: "Border Collie",
            payload: set_payload("pet_preferences", {pet: "dog", breed: "border_collie"})
          }
        ]
      },
      {
        title: "Cats",
        rows:[
          {
            title: "Persian",
            payload: set_payload("pet_preferences", {pet: "cat", breed: "persian"}),
          },
          {
            title: "Abyssinian",
            payload: set_payload("pet_preference", {pet: "cat", breed: "abyssinian"}),
          },
          {
            title: "Siamese",
            payload: set_payload("pet_preference", {pet: "cat", breed: "siamese"})
          }
        ]
      }
    ]
  }
)
```

### Header & Footer params

Both arguments <mark style="color:orange;">`header`</mark> and <mark style="color:orange;">`footer`</mark> are optional, please read more information in the [official WhatsApp documentation](https://developers.facebook.com/docs/whatsapp/cloud-api/reference/messages#interactive-messages).
