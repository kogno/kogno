---
description: Makes a delay between messages simulating a typing.
---

# typing

### <mark style="color:orange;">`typing(seconds=Integer)`</mark>

### **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

### Usage

```ruby
@reply.text "I'll wait 5 seconds before sending you another message."
@reply.typing 5
@reply.text "I'm back"
```

### Params

| Name                                                                                                                  | Description                                                   |
| --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>seconds</code></mark><br><mark style="color:orange;"><code></code></mark>Int</p> | <p><strong>Required.</strong></p><p>Wait time in seconds.</p> |
