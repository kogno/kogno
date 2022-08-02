---
description: Allows you to receive and answer an inline query  from Telegram.
---

# Telegram Inline Query

{% hint style="info" %}
Read more information about inlineQuery [here](https://core.telegram.org/bots/api#inlinequery), and before starting, it is necessary that this mode needs to be [enabled in Telegram](https://core.telegram.org/bots/api#inline-mode).
{% endhint %}

## Configuration

Define the context that will receive inline queries, by modify the field bellow in [`config/platforms/telegram.rb`](getting-started/telegram-configuration.md) configuration file.

```ruby
  config.routes.inline_query = :main
```

## Send Answers

In order to send answers to an inline query, call <mark style="color:orange;">`@reply.inline_query_result()`</mark> method:

### <mark style="color:orange;">`inline_query_result(type=Symbol, answer=Hash)`</mark>

### Params

| Name                                                                                                                  | Description                                                                                                                                                                                                                                                                                                  |
| --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| <p><mark style="color:orange;"><code>type</code></mark><br><mark style="color:orange;"><code></code></mark>Symbol</p> | <p><strong>Required.</strong></p><p>Can be <code>article</code>, <code>audio</code>, <code>contact</code>, <code>game</code>, <code>document</code>, <code>gif</code>, <code>location</code>, <code>mpeg4_gif</code>, <code>photo</code>, <code>venue</code>, <code>video</code> or <code>voice</code>. </p> |
| <p><mark style="color:orange;"><code>answer</code></mark><br><mark style="color:orange;"><code></code></mark>Hash</p> | <p><strong>Required.</strong><br>The answer, that varies depending on the type defined, read about the response formats for each type on <a href="https://core.telegram.org/bots/api#inlinequeryresult">Telegram documentation</a>.</p>                                                                      |

## Usage

When an inline query arrives, the configured context will handle it, through [action blocks](contexts/blocks/) that capture text messages such as [`keyword`](contexts/blocks/keyword.md), [`intent`](contexts/blocks/intent.md), [`entity`](contexts/blocks/entity.md), [`any_text`](contexts/blocks/any\_attachment-2.md) and so on.

In the next example, we've created a context called <mark style="color:orange;">`NewsContext`</mark>, which has been configured to handle inline queries as follows:

```ruby
  config.routes.inline_query = :news
```

This context will call two keyword blocks with the arguments <mark style="color:blue;">`"nytimes"`</mark> and <mark style="color:blue;">`"cnn"`</mark> respectively.  Each of them will return news extracted from the RSS service from the The New York Times or CNN.

```ruby
class NewsContext < Conversation

  def blocks
      
      keyword "nytimes" do 

        feed_entries("https://rss.nytimes.com/services/xml/rss/nyt/World.xml")[0..10].each do |article|
          @reply.inline_query_result(
            :article,
            {
              title: article.title,
              description: article.summary.to_s,
              url: article.url,
              thumb_url: article.image.to_s,
              photo_width: 128,
              photo_height: 128,
              input_message_content: {
                message_text: @reply.render_html_template(:news, :preview, {article: article}),
                parse_mode: "HTML"
              }
            }
          )
        end

      end

      keyword "cnn" do 
      
        if @msg.type == :inline_query
        
          feed_entries("http://rss.cnn.com/rss/edition_world.rss").each do |article|
            @reply.inline_query_result(
              :article,
              {
                title: article.title,
                description: article.summary.to_s,
                url: article.url,
                thumb_url: article.image.to_s,
                photo_width: 128,
                photo_height: 128,
                input_message_content: {
                  message_text: html_template("news/preview", {article: article}),
                  parse_mode: "HTML"
                }
              }
            )
          end
        else
        
          @reply.text "This example only works in Inline Mode for Telegram"
          
        end

      end
  
  end

  protected

  def feed_entries(url)
    xml = HTTParty.get(url).body
    feed = Feedjira.parse(xml)
    return feed.entries
  end

end
```

{% hint style="warning" %}
To implement this example you'll need to add the gems `feedjira` and `httparty` to the project's Gemfile.
{% endhint %}

### How would it look?

![](.gitbook/assets/inline\_query\_example.jpg)

### Shared content

In the example above, <mark style="color:orange;">`html_template("news/preview", {article: article})`</mark>  has been called, this method loads a template from `bot/templates/news/preview.rhtml` with the following code:

```ruby
<b><%=article.title%></b>
<i><%=article.summary.to_s.truncate(50)%></i>
<a href="<%=article.url%>"> Read more </a>
```

This content is what the person with whom the user is sharing the article will receive.

Learn more about `html_template()` method [here](global-methods.md#html\_template-route-string-params-hash).

