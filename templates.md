---
description: >-
  It calls a template with extension ".erb" and executes it. There may be just
  one or a serie of replies.
---

# Templates

### <mark style="color:orange;">`template(route=String, params=Hash)`</mark>

## Usage

```ruby
@reply.template "main/menu", { title: "But, I can help you with this" }
```

### File Location

```
bot/templates/main/menu.erb
```

Templates are found in sub-directories under `bot/templates/` and each sub-directory within has the same name as an existing context in a given project.&#x20;

For example: `bot/templates/`<mark style="color:orange;">`context_name`</mark>`/`<mark style="color:orange;">`template_name`</mark>`.erb`.&#x20;

### File Content

The code in the template must be written between the chars <mark style="color:orange;">`<% %>`</mark>.

```ruby
<%
  @reply.quick_reply(
    title,
    [
      {
        title: "Subscribe",
        payload: "profile/sign_up"
      },
      {
        title: "Follow US",
        payload: :twitter
      },
      {
        title: "Contact US",
        payload: :contact_us        
      }
    ]
  )
%>
```

### <mark style="color:orange;">`params`</mark> argument

The params argument can contain various elements which are accessed as a local variable within the template. In the example above: `title`.

## Arguments

| Name                                                                                                                            | Description                                                                                                                                                                                                                                                                 |
| ------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>route</code></mark><br><mark style="color:orange;"><code></code></mark><em>String</em></p> | <p><strong>Required.</strong></p><p>The template route.</p><p><strong>Formats:</strong></p><ul><li><code>"context_name/template_name"</code></li><li>"<code>template_name"</code> (If the template is in the same context from where this method was been called)</li></ul> |
| <p><mark style="color:orange;"><code>params</code></mark><br><mark style="color:orange;"><code></code></mark><em>Hash</em></p>  | <p><strong>Optional.</strong><br><strong></strong>Parameters that are passed to the template as local variables.</p>                                                                                                                                                        |

## Template reuse example

In the example below, the "main/menu" template will be called in 3 different situations in the conversation:

1. When the user sends a greeting..
2. When the user thanks..
3. When the app cannot understand what the user has said.

```ruby
class MainContext < Conversation

  def actions

    intent :gretting do
      @reply.text "Hello!"
      @reply.template "main/menu", { title: "How can I help you?" }
    end

    intent :thanks do
      @reply.text "You're welcome!"
      @reply.template "main/menu", { title: "Is there anything else I can help you with?" }
    end

    everything_else do
      @reply.text "Sorry, but I don't understand what you said."
      @reply.template "main/menu", { title: "But, I can help you with this" }
    end

  end

end
```
