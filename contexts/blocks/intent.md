---
description: >-
  This block will be executed if the intent provided as argument matches with
  the incoming message intent and if it was previously created and trained in
  the NLP engine.
---

# intent

### <mark style="color:orange;">`intent(name=String|Array, &block)`</mark>

{% hint style="success" %}
### Configuration

The NLP engine must be enabled and configured in [`bot/config/nlp.rb`](../../getting-started/nlp-configuration.md) file in order to implement this block.
{% endhint %}

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

In the following example, <mark style="color:orange;">`MainContext`</mark> will handle 3 different intentions:

* `greeting`: Greeting messages like "Hi", "Hello" and so on.
* `goodbye`: Goodbye messages like "Bye", "GodBye", "Goodnight" and so on.
* `thanks`: Thank you messages like "Thanks", "Thank you", "I appreciate it" and so on.

```ruby
class MainContext < Conversation

  def blocks

    intent "greeting" do
      @reply.text "Hello!"
    end

    intent "godbye" do
      @reply.text "Bye bye!"
    end

    intent "thanks" do
       @reply.text "You're welcome"
    end
  
end

```

### Example of how they look in Wit.ai

As we mention before, each intent must has been created and trained in the NLP Engine (in this case Wit.ai)

![](<../../.gitbook/assets/Screen Shot 2022-04-29 at 10.39.52.png>)

## Reading Params

This block passes 4 parameters that are: <mark style="color:orange;">`text`</mark>, <mark style="color:orange;">`entities`</mark>, <mark style="color:orange;">`traits`</mark> and <mark style="color:orange;">`confidence`</mark>, which contain additional information to the intention itself.

### Usage example

For the example below, let's assume the incoming message says the following:

_<mark style="color:blue;">"Please wake me up tomorrow at 7am. I'd really appreciate it"</mark>_

Assuming also that we have been created and trained an intent called <mark style="color:orange;">`set_alarm`</mark>, that is linked to the entity <mark style="color:purple;">`wit/datetime`</mark> and the trait <mark style="color:purple;">`wit/sentiment`</mark>.

![Wit.ai screenshot](<../../.gitbook/assets/Screen Shot 2022-04-30 at 10.12.56.png>)

In the code below, thanks to these parameters the block can send an even more appropriate reply:

```ruby
class MainContext < Conversation

  def blocks
  
    intent :set_alarm do |text, entities, traits, confidence|
    
       unless entities["wit$datetime:datetime"].nil?
       
          entity = entities["wit$datetime:datetime"].first
          @reply.text "I'll wake you up at #{entity[:value]}"
          
       else
       
          @reply.text "To help you with that, I need you to tell me a time for the alarm."
          
       end
       
       @reply.typing 1.second
       
       unless traits["wit$sentiment"].nil?
       
          trait = traits["wit$sentiment"].first
          case trait[:value]
             when "positive"
             
                @reply.text "And thank you for asking so kindly."
                
             when "negative"
             
                @reply.text "But you could try to be nicer next time.."
                
             when "neutral"
                # Nothing here
          end
       end
       
    end
  
end
```

### Params definition

#### <mark style="color:orange;">`text`</mark>

Just the text message <mark style="color:blue;">"</mark>_<mark style="color:blue;">Please wake me up tomorrow at 7am. I'd really appreciate it</mark>_<mark style="color:blue;">"</mark>

#### <mark style="color:orange;">`entities`</mark>

Array with the entities found.

```json
{
  "wit$datetime:datetime": [
    {
      "id": "313292537627827",
      "name": "wit$datetime",
      "role": "datetime",
      "start": 38,
      "end": 53,
      "body": "tomorrow at 7am",
      "confidence": 0.9995,
      "entities": [

      ],
      "type": "value",
      "grain": "hour",
      "value": "2022-04-30T07:00:00.000-07:00",
      "values": [
        {
          "type": "value",
          "grain": "hour",
          "value": "2022-04-30T07:00:00.000-07:00"
        }
      ]
    }
  ]
}
```

#### <mark style="color:orange;">`traits`</mark>

Array with the traits found.

```json
{
  "wit$sentiment": [
    {
      "id": "5ac2b50a-44e4-466e-9d49-bad6bd40092c",
      "value": "positive",
      "confidence": 0.9047
    }
  ]
}
```

#### <mark style="color:orange;">`confidence`</mark>

The percentage of confidence of the NLP engine in associating the message with the intent.

<mark style="color:green;">`0.998`</mark>

## `any_intent` Block

Catch any intent of the message and returns 5 parameters: <mark style="color:orange;">`intent`</mark>, <mark style="color:orange;">`text`</mark>, <mark style="color:orange;">`entities`</mark>, <mark style="color:orange;">`traits`</mark> and <mark style="color:orange;">`confidence`</mark>.

### Usage

```ruby
class MainContext < Conversation

  def blocks

    any_intent do |intent|
      if intent == "gretting"
        @reply.text "Hello!"
      elsif intent == "godbye"
        @reply.text "Bye bye!"
      elsif intent == "thanks"
        @reply.text "You're welcome" 
      end 
    end
  
  end

end
```

{% hint style="success" %}
### Routing to Context

An intent can be routed to a specific context, learn how in [Routing Chapter](../routing.md#intent).
{% endhint %}
