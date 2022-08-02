---
description: >-
  Creates messages or making calls to the each platform API, by sending specific
  raw parameters for each of them.
---

# raw

## <mark style="color:orange;">`raw(params=Hash, type=String)`</mark>

### **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

For the correct operation of this method, there are parameters on each platform that must not be included, since Kogno will include them subsequently.

### Messenger

Example call extracted from [Messenger Documentation](https://developers.facebook.com/docs/whatsapp/cloud-api/guides/send-messages#text-messages)&#x20;

```bash
curl -X POST -H "Content-Type: application/json" -d '{
  "recipient":{
    "id":"<PSID>"
  },
  "message":{
    "text":"hello, world!"
  }
}' "https://graph.facebook.com/v14.0/me/messages?access_token=<PAGE_ACCESS_TOKEN>"
```

The <mark style="color:orange;">`params`</mark> in <mark style="color:orange;">`raw()`</mark> method will populate the `"message"` field from the JSON in the call above.

```ruby
@reply.raw(
  {
    :text => "Hello, world!"
  }
)
```

### WhatsApp

Example call extracted from [WhatsApp Documentation](https://developers.facebook.com/docs/whatsapp/cloud-api/guides/send-messages#text-messages)

```bash
curl -X  POST \
 'https://graph.facebook.com/v13.0/FROM_PHONE_NUMBER_ID/messages' \
 -H 'Authorization: Bearer ACCESS_TOKEN' \
 -d '{
  "messaging_product": "whatsapp",
  "recipient_type": "individual",
  "to": "PHONE_NUMBER",
  "type": "text",
  "text": { // the text object
    "preview_url": false,
    "body": "Hello, world!"
  }
}'
```

Must not be included the following params: <mark style="color:red;">`messaging_product`</mark> and <mark style="color:red;">`recipient_type`</mark> since Kogno will include them subsequently.

```ruby
@reply.raw(
  {
    type: :text,
    text: {
      body: "Hello, world!"
    }
  } 
)
```

### Telegram

Only <mark style="color:red;">`chat_id`</mark> must not be included, for more information read the [Telegram documentation](https://core.telegram.org/bots/api#sendmessage).

```ruby
@reply.raw(
  {
    :text => "Hello, world!"
  }
)
```

Additionally, in Telegram, the argument <mark style="color:orange;">`type`</mark> can be passed with values like `"sendPhoto"`, `"sendAudio"`, `"forwardMessage"` and so on. If none is defined, by default the method used will be `"sendMessage"`.&#x20;

&#x20;View [Full Available Methods in Telegram](https://core.telegram.org/bots/api#available-methods).

```ruby
@reply.raw(
  {
    :photo => "https://www.gitbook.com/cdn-cgi/image/width=32,height=32,fit=contain,dpr=2,format=auto/https%3A%2F%2Ffiles.gitbook.com%2Fv0%2Fb%2Fgitbook-x-prod.appspot.com%2Fo%2Fspaces%252F-LvKT8QLxtgmljG5_-j1%252Ficon%252FNq9E3zigmAxZ0dgztUo0%252Flogo.png%3Falt%3Dmedia%26token%3D4fe5ec39-04ff-4572-836c-3aad704c3785"
  },
  "sendPhoto"
)
```
