---
description: >-
  This block captures an NLP entity regardless of the incoming message
  intention.
---

# entity

### <mark style="color:orange;">`entity(name=String, &block)`</mark>

{% hint style="success" %}
### Configuration

The NLP engine must be enabled and configured in [`bot/config/nlp.rb`](../../getting-started/nlp-configuration.md) file in order to implement this block.
{% endhint %}

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

For this example, we will use the entity <mark style="color:purple;">`wit$datetime:datetime`</mark> <mark style="color:purple;"></mark><mark style="color:purple;"></mark> (Wit.ai Built-In)

And suppose the following message arrives:

&#x20;<mark style="color:blue;">**"tomorrow at 7am"**</mark>

As you can see in this message, there is no clear intention. But implementing this block, where we send a reply with two options, we can try to understand the message intention.

```ruby
class MainContext < Conversation

  def blocks

    entity "wit$datetime:datetime" do |values|    
      datetime = values.first[:value]
      @reply.quick_reply(
        "What do you want me to alert at #{datetime}?",
        [
          {
            title: "Set Alarm",
            payload: set_payload("alarms/new")
          },
          {
            title: "Set a Reminder",
            payload: set_payload("reminders/new")
          }
        ]
      )      
    end
  
  end
  
end
```

## Custom entities

To further understand how entities work, we will create in Wit.ai an entity called <mark style="color:purple;">`colors`</mark> where we will train the NLP engine with various color options.

{% hint style="success" %}
The entity can be created and trained directly from the Wit.ai Dashboard or [via API](https://wit.ai/docs/http/20220503/) for which Kogno has a method.
{% endhint %}

### Create a custom entity

On the project's directory, open the console by running the `kogno c` command and then execute the following:

```ruby
nlp = Kogno::Nlp.new
nlp.wit.entity_create(
  {
    name: "color",
    roles: ["name"],
    lookups: ["keywords"],
    keywords:[
      {keyword: "red", synonyms: ["Red"]},
      {keyword: "orange", synonyms: ["Orange"]},
      {keyword: "Yellow", synonyms: ["Yellow"]},
      {keyword: "Green", synonyms: ["Green"]},
      {keyword: "Cyan", synonyms: ["Cyan"]},
      {keyword: "Blue", synonyms: ["Blue"]},
      {keyword: "Magenta", synonyms: ["Magenta"]},
      {keyword: "Purple", synonyms: ["Purple"]},
      {keyword: "White", synonyms: ["White"]},
      {keyword: "Black", synonyms: ["Black"]},
      {keyword: "Gray", synonyms: ["Gray","Gray"]},
      {keyword: "Silver", synonyms: ["Silver"]},
      {keyword: "Pink", synonyms: ["Pink"]},
      {keyword: "Maroon", synonyms: ["Maroon"]},
      {keyword: "Brown", synonyms: ["Brown"]},
      {keyword: "Beige", synonyms: ["Beige"]},
      {keyword: "Tan", synonyms: ["Tan"]},
      {keyword: "Peach", synonyms: ["Peach"]},
      {keyword: "Lime", synonyms: ["Lime"]},
      {keyword: "Olive", synonyms: ["Olive"]},
      {keyword: "Turquoise", synonyms: ["Turquoise"]}
    ]
  }
)
```

This will create the <mark style="color:purple;">`color`</mark> entity with the role <mark style="color:purple;">`name`</mark>.&#x20;

### Usage

In the following example, <mark style="color:orange;">`MainContext`</mark> will catch any incoming messages such as: <mark style="color:blue;">"I want a blue t-shirt"</mark>, <mark style="color:blue;">"grass is green"</mark> and so on.

```ruby
class MainContext < Conversation

  def blocks

    entity "color:name" do |values|  
      color = values.first[:value]
      @reply.text "You've said the color #{color}!"    
    end
  
  end
  
end
```
