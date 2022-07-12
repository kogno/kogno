class Kogno::Context

  @@callbacks = {} # class callbacks: after_initialize,before_blocks, before_exit, after_blocks
  @@expiration_time = {}

  def initialize(user,msg,notification,temp_context=nil,notification_group=nil,chat=nil)

    @user = user
    @chat = chat || @user
    @message = msg
    @reply = notification
    @reply_group = notification_group

    # return true if call_expiration_time()

    @sub_contexts = []
    @sub_context_route = ""
    # @sub_contexts = {}
    @sub_contexts_tree = []

    @blocks = {
      deep_link: {},      
      anything: {},
      before: {},
      intents: {},
      commands: {},
      expressions: {},
      postbacks: {},
      stickers: {},
      attachments: {},
      keywords: {},
      regular_expressions: {},
      any_number: {},
      any_text: {},
      location: {},
      nlp_entities: {},
      nlp_datetime_range: {},
      nlp_location: {},
      nlp_search_query: {},
      nlp_datetime: {},
      nlp_duration: {},
      any_postback: {},
      any_intent: {},
      everything_else: {},
      after: {},
      membership_new: {},
      membership_drop: {},
      recurring_notification: {}      
    }

    @sequences={}
    @current_sequence_stage = nil

    @impact = :self
    @deep_blocks = Marshal.load(Marshal.dump(@blocks))

    @callbacks = {
      before_delegate:{},
      on_delegate:{},
      on_exit:{},
      on_enter:{}
    }


    @halt = false
    @continue = false

    # self.class.after_initialize()

    @reply.set_context(self)
    @reply_group.set_context(self) unless @reply_group.nil?
    @context = self

    @current = temp_context.nil? ? @user.context : temp_context
    # @current = Kogno::Application.config.routes.default if @current.nil? || @current.empty?

    @memorized_message = nil

    @current_action = {
      action: nil,
      value: nil    
    }

    @called_block = {
      action: nil,
      value: nil,
      params: nil,
      context: nil,
      deep: false
    }

    call_class_callback(:after_initialize)

  end

  def self.expiration_in(expiration_time)
    @@expiration_time[self] = expiration_time
  end

  def self.after_initialize(method)
    self.set_class_callback(:after_initialize, method)
  end

  def self.before_blocks(method)
    self.set_class_callback(:before_blocks, method)
  end

  def self.before_exit(method)
    self.set_class_callback(:before_exit, method)
  end

  def self.after_blocks(method)
    self.set_class_callback(:after_blocks, method)
  end

  def self.set_class_callback(action,method)
    @@callbacks[self] = {} if @@callbacks[self].nil?
    @@callbacks[self][action] = [] if @@callbacks[self][action].nil?
    @@callbacks[self][action].push(method)
  end

  def set_block(action, input, impact, block)

    if input.nil?
      @blocks[action][@sub_context_route] = block
      if impact == :deep
        # logger.write "---- ADD DEEP IMPACT TO #{action}", :red
        @deep_blocks[action] = block
      end
    else
      @blocks[action][@sub_context_route] = {} if @blocks[action][@sub_context_route].nil?
      @blocks[action][@sub_context_route][input] = block
      if impact == :deep
        @deep_blocks[action][input] = block
        # logger.write "---- ADD DEEP IMPACT TO #{action}(#{imput})", :red
      end
    end

    # if impact == :deep
    #   @deep_blocks[action][input] = block
    # end

  end

  def deep
    @impact = :deep
    self
  end

  def before(section, &block)

    set_block(:before, section, @impact, block)
    @impact = :self

  end

  def after(section, &block)

    set_block(:after, section, @impact, block)
    @impact = :self

  end

  def before_anything(&block)

    before :blocks do
      block.call
    end
    @impact = :self

  end

  def after_all(&block)

    after :blocks do
      block.call
    end
    @impact = :self

  end

  def membership(type, &block)
    if type == :new
      set_block(:membership_new, nil, :self, block)
    elsif type == :drop
      set_block(:membership_drop, nil, :self, block)
    end
  end
  
  def recurring_notification(type, &block)
    set_block(:recurring_notification, type, :self, block)
  end


  def deep_link(&block)
    set_block(:deep_link, nil, @impact, block)
    @impact = :self
  end

  def intent(input, &block)
    if input.class == Array
      input.each do |i|
        set_block(:intents, i.to_s.downcase, @impact, block)
      end
    else
      set_block(:intents, input.to_s.downcase, @impact, block)
    end  
    @impact = :self   
  end

  def command(input, &block) # Telegram only
    set_block(:commands, input.to_s.downcase, @impact, block)
    @impact = :self
  end

  def expression(input, &block)
    set_block(:expressions, input, @impact, block)
    @impact = :self
  end

  def inline_query(&block)
    sub_context :inline_query do
      block.call
    end
  end

  def postback(input, &block)
    if input.class == Array
      input.each do |i|
        set_block(:postbacks, i.to_s.downcase, @impact, block)
      end
    else
      set_block(:postbacks, input.to_s.downcase, @impact, block)
    end
    @impact = :self
  end

  def sticker(input, &block)
    set_block(:stickers, sticker_id, @impact, block)
    @impact = :self
  end
  
  def any_attachment(&block)
    set_block(:attachments, nil, @impact, block)
    @impact = :self
  end

  def keyword(input, &block)
    if input.class == Array
      input.each do |i|
        set_block(:keywords, i.to_s.downcase, @impact, block)
      end
    else
      set_block(:keywords, input.to_s.downcase, @impact, block)      
    end 
    @impact = :self
  end

  def regular_expression(input, &block)
    set_block(:regular_expressions, input, @impact, block)
    @impact = :self
  end

  def location(&block)
    set_block(:location, nil, @impact, block)
    @impact = :self
  end

  def nlp_entity(input, &block)
    set_block(:nlp_entities, input.to_s.downcase.to_sym, @impact, block)
    @impact = :self
  end

  def entity(input, &block)
    nlp_entity(input, &block)
    @impact = :self
  end

  def datetime(&block)
    entity "wit$datetime:datetime" do |values|
      block.call values.map{|v| v[:value] || v[:from][:value] rescue nil}
    end
    @impact = :self
  end


  def duration(&block)
    entity "wit$duration:duration" do |values|
      block.call values
    end
    @impact = :self
  end

  def nlp_location(&block)
    nlp_entity("wit$location:location", &block)
    @impact = :self
  end

  def datetime_range(&block)
    set_block(:nlp_datetime_range, nil, @impact, block)
  end

  def anything(&block)
    set_block(:anything, nil, @impact, block)
    @impact = :self
  end

  def any_number(&block)
    set_block(:any_number, nil, @impact, block)
    @impact = :self
  end

  def any_text(&block)
    set_block(:any_text, nil, @impact, block)
    @impact = :self
  end

  def any_postback(&block)
    set_block(:any_postback, nil, @impact, block)
    @impact = :self
  end

  def any_intent(&block)
    set_block(:any_intent, nil, @impact, block)
    @impact = :self
  end

  def everything_else(&block)
    set_block(:everything_else, nil, @impact, block)
    @impact = :self
  end

  def callback(callback_name,&block)
    @callbacks[callback_name.to_sym][@sub_context_route] = block
  end

  # CallBacks shortcuts

  def before_delegate(&block)
    callback :before_delegate do
      block.call
    end
  end

  def on_delegate(&block)
    callback :on_delegate do
      block.call
    end
  end

  def on_exit(&block)
    callback :on_exit do
      block.call
    end
  end

  def on_enter(&block)
    callback :on_enter do
      block.call
    end
  end

  #---

  # def opt_out(route=nil,type=:change,impact=:self,&block)

  #   if route.nil?
  #       opt_out_block = block # you define what to do in opt_out
  #   elsif type==:delegate

  #     if route == :main # Goes to main context
  #       opt_out_block = proc {delegate_to("main")}
  #     elsif route == :parent #Goes to parent context, if isn't. Goes go main
  #       opt_out_block = proc {delegate_to(self.parent_context_route)}
  #     elsif route == :root #Goes to root contexts, not main.
  #       opt_out_block = proc {delegate_to(self.root_context_route)}
  #     else
  #       opt_out_block = proc {delegate_to(route)}
  #     end

  #   else  # :change

  #     if route == :main or route == :exit # Goes to main context
  #       opt_out_block = proc {change_to("main", true)}
  #     elsif route == :parent #Goes to parent context, if isn't. Goes go main
  #       opt_out_block = proc {change_to(self.parent_context_route, true)}
  #     elsif route == :root #Goes to root contexts, not main.
  #       opt_out_block = proc {change_to(self.root_context_route, true)}
  #     else
  #       opt_out_block = proc {change_to(route, true)}
  #     end

  #   end

  #   expression "CANCEL", impact do
  #     opt_out_block.call
  #   end

  #   postback "LEAVE_CONTEXT", impact do
  #     opt_out_block.call
  #   end

  # end

  def sub_context(route, &block)
    @sub_contexts_tree.push(route)
    @sub_context_route = @sub_contexts_tree.join(".")    
    @sub_contexts.push(@sub_context_route)
    if in_route? # The sub_context to execute will be only the ones that are in the route of the current context.
      # @halt = {@sub_context_route => false}
      block.call @user.get_context_params
    end
    @sub_contexts_tree.pop
    @sub_context_route = @sub_contexts_tree.join(".")
  end

  def answer(route, &block)
    sub_context route do |params|
      block.call params
    end
  end

  def halt(silent=false)
    logger.write("********** HALT **********", :red) unless silent
    @halt = true
  end

  def halted?
    @halt
  end

  def continue
    @continue = true
  end

  def continue?
    if @continue
      logger.write "********** CONTINUE **********", :red
      @continue = false
      return true
    else
      return false
    end
  end

  def in_route?
    current_sub_context = current_sub_context()
    if current_sub_context.include?("#{@sub_context_route}.") or @sub_context_route == current_sub_context
      true
    else
      false
    end
  end

# CALLS

  def call_block(action, params=nil, input=:empty)
    @current_action = {
      name: action,
      value: input == :empty ? nil : input
    }
    if input.nil?
      return false
    elsif input == :empty
      block = @blocks[action][current_sub_context()] rescue nil
    else
      block = @blocks[action][current_sub_context()][input] rescue nil
    end
    if block.class == Proc
      logger_call(action, input, params, true)
      if params.class == Kogno::BlockParams
        block.call params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7]
      else
        block.call params
      end      
      unless continue?
        @called_block = {
          name: action,
          value: input == :empty ? nil : input,
          params: params,
          context: @current,
          deep: false
        }        
        return true
      else
        logger_call(action, input, [], false)
        return false
      end
    else
      if input == :empty
        deep_action_block = @deep_blocks[action] rescue nil
      else
        deep_action_block = @deep_blocks[action][input] rescue nil
      end

      if deep_action_block.class == Proc  
        logger_call(action, input, params, true, true)    
        if params.class == Kogno::BlockParams
          deep_action_block.call params[0], params[1], params[3], params[4], params[5], params[6], params[7]
        else
          deep_action_block.call params
        end        
        unless continue?
          @called_block = {
            name: action,
            value: input == :empty ? nil : input,
            params: params,
            context: @current,
            deep: true
          }
          return true
        else
          logger_call(action, input, [], false)
          return false
        end
      else
        logger_call(action, input, [], false)
        return false
      end
    end
  end

  def call_before(section=:blocks, values=nil)
    return true if halted?
    call_block(:before, values, section)
  end

  def call_after(section=:blocks, values=nil)
    return true if halted?
    call_block(:after, values, section)
  end


  def call_membership_new
    if @message.type == :chat_activity and @message.chat_membership_status      
      return call_block(:membership_new, @message.chat)
    end
    return false
  end

  def call_membership_drop
    if @message.type == :chat_activity and !@message.chat_membership_status      
      return call_block(:membership_drop, @message.chat)
    end
    return false
  end

  def call_deep_link
    if !@message.referral(:ref).nil?
      return true if halted?
      param = @message.deep_link_param || @message.referral(:ref)
      call_block(:deep_link, param)
    elsif !@message.deep_link_data.nil?
      param = @message.deep_link_param || @message.deep_link_data
      call_block(:deep_link, param)
    else
      return false
    end  
  end

  def call_recurring_notifications
    return false if @message.type != :recurring_notification
    if @message.notification_messages_status == :active
      return call_block(:recurring_notification, @user.messenger_recurring_notification.data, :granted)
    elsif @message.notification_messages_status == :stopped
      return call_block(:recurring_notification, @user.messenger_recurring_notification.data, :removed)
    else
      return false
    end
    
  end

  def call_anything
    call_block(:anything)
  end

  def call_intents
    intent_data = @message.nlp.intent(false)
    intent = intent_data[:name] rescue nil
    confidence = intent_data[:confidence] rescue nil
    unless intent.nil?
      context_in_intent = self.class.get(intent)
      new_context = nil
      unless context_in_intent.nil?
        new_context = context_in_intent[:context]
        intent = context_in_intent[:param]
      end
      if !new_context.nil? && self.name != new_context
        # new_context = "#{new_context}.inline_query" if @message.type == :inline_query
        logger_call(:intents, intent, [], true)
        if self.delegate_to("/#{new_context}")
          halt
          return true
        else
          return false
        end  
      else  
        return true if halted?
        block_response = call_block(:intents, Kogno::BlockParams.new([@message.text, @message.nlp.entities, @message.nlp.traits, confidence]), intent)
        block_response = call_any_intent(Kogno::BlockParams.new([intent, @message.text, @message.nlp.entities, @message.nlp.traits, confidence])) unless block_response
        return block_response
      end  
    else
      return false
    end
  end

  def call_commands
    return false unless @message.platform == :telegram
    command = @message.command    
    unless command.nil?
      @message.nlp.process_phrase(@message.command_text)
      block_response = call_block(:commands, Kogno::BlockParams.new([@message.command_text, @message.nlp.entities, @message.nlp.traits]), command)
      if block_response
        return block_response
      else
        default_context = get_default_context_for_command(command)
        unless self.name == default_context.to_s
          logger_call(:commands, command, [], true)
          if self.delegate_to(default_context)
            halt
            return true
          else
            return false
          end 
        else
          false
        end
      end
    else
      return false
    end
  end

  # def call_expressions
  #   expression = @message.nlp.expression

  #   unless expression.nil?
  #     call_before(:expressions)
  #     return true if halted?

  #     block_response = call_block(:expressions, nil, expression)
  #     call_after(:expressions)
  #     return block_response
  #   else
  #     return false
  #   end
  # end


  def self.get_from_typed_postback(msg,user)
    typed_postbacks = user.vars[:typed_postbacks]
    keyword = msg.text.to_payload
    postback = (typed_postbacks[keyword] rescue nil)
    return(self.get_from_payload(postback))
  end

  def call_typed_postbacks
    # expression = @message.nlp.expression
    typed_postbacks = @user.vars[:typed_postbacks]
    @user.vars.delete(:typed_postbacks)

    if !@message.text.nil?
      keyword = @message.text.to_payload
      logger_call("typed_postbacks", keyword, [], false)
      postback = (typed_postbacks[keyword] rescue nil)
      unless postback.nil?
        logger.write "KEYWORD FOUND:#{postback.to_yaml}", :green
        @message.overwrite_postback(postback)
        return call_postbacks()
      end

    end
    return false
  end

  def call_postbacks(triggers=true)
    postback = @message.payload(true)
    unless postback.nil?
      postback = postback.downcase
      block_params = Kogno::BlockParams.new([postback, @message.params])
      # call_before(:postbacks, block_params) if triggers
      return true if halted?
      block_response = call_block(:postbacks, @message.params, postback)
      block_response = call_any_postback(block_params) unless block_response
      # call_after(:postbacks, block_params) if triggers
      return block_response
    else
      return false
    end
  end

  # def call_stickers
  #   block_response = false
  #   unless @message.stickers.empty?
  #     call_before(:stickers)
  #     return true if halted?
  #     @message.stickers.each do |sticker|
  #       block_response = call_block(:stickers, nil, sticker)
  #     end
  #     block_response = call_block(:stickers, nil, "*") unless block_response
  #     call_after(:stickers)
  #     return block_response
  #   else
  #     return false
  #   end
  # end

  def call_keywords
    keyword = @message.text.downcase.strip
    unless keyword.empty?

      # call_before(:keywords)
      return true if halted?

      block_response = call_block(:keywords, nil ,keyword)
      # call_after(:keywords)
      return block_response
    else
      return false
    end
  end

  def call_regular_expressions
    text = @message.text.upcase
    regular_expressions = @blocks[:regular_expressions][current_sub_context()]
    unless regular_expressions.nil?
      regular_expressions.each do |regular_expression,block|
        @current_action = {
          name: :regular_expressions,
          value: regular_expression,
          deep: false
        }        
        matches = text.scan(regular_expression)
        if matches.count > 0
          logger_call("regular_expression", regular_expression, matches, true)
          block.call matches
          @called_block = {
            name: :regular_expressions,
            value: regular_expression,
            params: nil,
            context: @current,
            deep: false
          }          
          return true unless continue?
        end
      end
    end
    deep_regular_expressions = @deep_blocks[:regular_expressions][current_sub_context()]
    unless deep_regular_expressions.nil?
      deep_regular_expressions.each do |regular_expression,block|
        @current_action = {
          name: :regular_expressions,
          value: regular_expression,
          deep: true
        }
        matches = text.scan(regular_expression)
        if matches.count > 0
          logger_call("regular_expression", regular_expression, matches, true, true)
          block.call matches
          @called_block = {
            name: :regular_expressions,
            value: regular_expression,
            param: nil,
            context: @current,
            deep: true
          } 
          return true unless continue?
        end
      end
    end
    logger_call("regular_expression", nil, [], false)
    return false
  end

  def call_location
    unless @message.location.nil?
      # call_before(:location)
      # return true if halted?

      block_response = call_block(:location, @message.location)
      # call_after(:location)
      return block_response
    else
      return false
    end
  end

  def call_nlp_entity
    block_response = false
    # call_before(:nlp_entity)
    # return true if halted?
    
    if @message.nlp.datetime_range?
      range = @message.nlp.datetime_range
      block_response = call_block(:nlp_datetime_range, Kogno::BlockParams.new([range[:from], range[:to]])) 
    end
    
    unless block_response
      @message.nlp.entities.each do |entity,values|
        return true if block_response
        block_response = call_block(:nlp_entities, values, entity)
      end
    end
    # call_after(:nlp_entity) if block_response
    return block_response
  end

  def call_any_number
    if @message.numbers_in_text.count > 0
      block_response = call_block(:any_number, @message.numbers_in_text)
      return block_response

    else
      return false
    end
  end

  def call_any_text
    unless @message.text.empty?
      return call_block(:any_text, @message.text)
    else
      return false
    end
  end

  def call_any_attachment
    unless @message.attachments.nil?
      return call_block(:attachments, @message.attachments)
    else
      return false
    end
  end

  def call_any_postback(block_params)
    unless @message.payload.nil?
      return call_block(:any_postback, block_params)
    else
      return false
    end
  end

  def call_any_intent(block_params)
    unless @message.nlp.intent.nil?
      return call_block(:any_intent, block_params)
    else
      return false
    end
  end

  def call_everything_else
    params = @message.type == :post_comment ? { text: @message.text } : { text: @message.text, payload: @message.payload, entities: @message.nlp.entities, traits: @message.nlp.traits }
    return call_block(:everything_else, params)
  end

  def call_callback(callback_name)
    callback_block = (@callbacks[callback_name.to_sym][current_sub_context()] rescue nil)
    unless callback_block.nil?
      logger_call("callback", callback_name, [], true)
      callback_block.call
      return true
    else
      logger_call("callback", callback_name, [], false)
      return false
    end
  end

  def call_class_callback(callback_name)
    conversation_methods = (@@callbacks[Conversation][callback_name].uniq rescue [])
    class_methods = (@@callbacks[self.class][callback_name] rescue [])
    methods = []
    methods += conversation_methods unless conversation_methods.nil?
    methods += class_methods unless class_methods.nil?
    if methods.length > 0
      methods.each do |method|
        if !method.nil? and !halted?
          logger.write "\t#{method}() method found", :red
          self.send(method)
        end
      end
    end
  end

  def self.class_callbacks
    @@callbacks
  end

  def call_expiration_time
    unless @@expiration_time[self.class].nil?
      if @user.last_usage > @@expiration_time[self.class]
        delegate_to(:main, true)
        return true
      end
    end
    return false
  end

  def current_sub_context
    context_tree = @current.to_s.split(Regexp.union(["/","."]))
    context_tree.shift
    return context_tree.join(".")
  end

  def parent_context_route(context_path=nil)
    context_tree = context_path.nil? ? @current.to_s.split(Regexp.union(["/","."])) : context_path.split(Regexp.union(["/","."]))
    context_tree.pop
    return context_tree.join(".")
  end

  def root_context_route(context_path=nil)
    context_tree = context_path.nil? ? @current.to_s.split(Regexp.union(["/","."])) : context_path.split(Regexp.union(["/","."]))
    return context_tree.first
  end

  def current_context_route
    if @current.nil? || @current.empty?
      self.name
    else
      @current
    end
  end

  def valid_context_route?
    if @current.nil? || @current.empty?
      return true
    elsif @current == self.name
      return true
    elsif @sub_contexts.include?(current_sub_context())
      return true
    else
      return false
    end
  end

  def nlp_entities_present?(entities)
    (entities & @message.nlp.entities.keys).present?
  end


  def run(args={run_blocks_method: true, ignore_everything_else: false})

    @run_type = :full

    logger.write "\n\n#{self.nice_current_route} => Starting matching process\n", :bright

    # before_blocks()

    call_class_callback(:before_blocks)

    unless halted?
      blocks() if args[:run_blocks_method] #Loading blocks

      unless self.valid_context_route?
        logger.write "Error: the context in route #{@current} doesn't exist", :red
        self.exit_context()
        return false
      end

      call_before(:blocks)

      if !call_location() and !halted? # Deprecated
        if !call_postbacks() and !halted?
          if !call_typed_postbacks() and !halted?
            if !call_deep_link() and !halted?
              if !@message.empty?
                if !call_commands() and !halted? # Telegram only
                  # if !call_stickers() and !halted?
                    if !call_any_attachment() and !halted?
                      if !call_regular_expressions() and !halted?
                        if !call_keywords() and !halted?
                          call_before(:nlp)
                          @message.nlp.process_phrase_once
                          call_after(:nlp, @message.nlp.entities)
                          # if !call_expressions() and !halted?
                            if !call_intents() and !halted?
                              if !call_nlp_entity() and !halted?
                                if !call_any_number() and !halted?
                                  if !call_any_text() and !halted?                                     
                                    unless args[:ignore_everything_else]
                                      if !call_everything_else() and !halted?
                                        logger.write "\tNo match found in #{@current}", :yellow
                                        call_after(:blocks)
                                        call_class_callback(:after_blocks)
                                        return false
                                      end
                                    else
                                      return false
                                    end
                                  end
                                end
                              end
                            end
                          # end
                        end 
                      end
                    end  
                  # end
                end 
              else
                logger.write "---- THIS MESSAGE IS EMPTY ----", :red  
              end 
            end
          end
        end
      end
      unless halted?
        call_after(:blocks)
        call_class_callback(:after_blocks)
      end
    end
    return @called_block
  end

  def run_class_callbacks_only
    call_class_callback(:before_blocks)
    unless halted?
      call_class_callback(:after_blocks)
    end
  end

  def run_for_text_only(args={run_blocks_method: true, ignore_everything_else: false})

    @run_type = :text_only

    logger.write "\n\n#{self.nice_current_route} => Starting matching process (text only)\n", :bright

    # before_blocks()

    call_class_callback(:before_blocks)

    unless halted?
      blocks() if args[:run_blocks_method] #Loading blocks

      unless self.valid_context_route?
        logger.write "Error: the context in route #{@current} doesn't exist", :red
        self.exit_context()
        return false
      end

      call_before(:blocks)
      if !@message.empty?
        if !call_regular_expressions() and !halted?
          if !call_keywords() and !halted?
            call_before(:nlp)
            @message.nlp.process_phrase_once
            call_after(:nlp, @message.nlp.entities)
            # if !call_expressions() and !halted?              
              if !call_intents() and !halted?
                if !call_nlp_entity() and !halted?                    
                  if !call_any_number() and !halted?
                    if !call_any_text() and !halted?
                      unless args[:ignore_everything_else]
                        if !call_everything_else() and !halted?
                          logger.write "#{self.class.name.to_s}.run_for_text_only => nothing found | #{@current}", :yellow
                          call_after(:blocks)
                          call_class_callback(:after_blocks)
                          return false
                        end
                      else
                        return false
                      end
                    end
                  end
                end
              end
            # end
          end 
        end
      else
        logger.write "---- THIS MESSAGE IS EMPTY AND WE DON'T DOING NOTHING WITH IT ----", :red  
      end 
      unless halted?
        call_after(:blocks)
        call_class_callback(:after_blocks)
      end
    end
    return @called_block
  end  

  def run_for_chat_activity_only(args={run_blocks_method: true, ignore_everything_else: false})

    @run_type = :text_only

    logger.write "\n\n#{self.nice_current_route} => Starting matching process (chat activity only)\n", :bright


    call_class_callback(:before_blocks)

    unless halted?
      blocks() if args[:run_blocks_method] #Loading blocks

      unless self.valid_context_route?
        logger.write "Error: the context in route #{@current} doesn't exist", :red
        self.exit_context()
        return false
      end

      call_before(:blocks)
      if !call_membership_new()
        if !call_membership_drop()
          logger.write "#{self.nice_current_route}.run_for_chat_activity_only => nothing found", :yellow
          call_after(:blocks)
          call_class_callback(:after_blocks)
        end
        return false
      end 
    end

    return @called_block
  end

  def run_for_recurring_notification_only()

    @run_type = :text_only

    logger.write "\n\n#{self.nice_current_route} => Starting matching process (recurring notification only)\n", :bright
    


    call_class_callback(:before_blocks)

    unless halted?
      blocks()

      unless self.valid_context_route?
        logger.write "Error: the context in route #{@current} doesn't exist", :red
        self.exit_context()
        return false
      end

      call_before(:blocks)
      call_recurring_notifications()
      if !call_postbacks(false) and !halted?
        call_class_callback(:after_blocks)
        return false
      end          
    end

    call_class_callback(:after_blocks)
    return @called_block

  end 

  def name
    self.class.to_s.underscore.sub("_context","")
  end

  def type
    :context
  end

  def self.router(route,type=:default)
    type = :default if type.to_sym == :message
    context_class = nil
    sub_context_route = nil
    if route.to_s.empty?
      context_class = "#{Kogno::Application.routes.to_h[type.to_s]}_context".classify
    else
      route_array = route.to_s.split(Regexp.union(["/","."]))
      context_name = route_array[0]
      sub_context_route = route_array[1..].join(".")
      context_class = "#{context_name}_context".classify
    end

    valid_class = (eval(context_class) rescue nil)
    if valid_class.nil?
      valid = false
    else
      valid = true
      context_class = valid_class
    end
    return (
      {
        class: context_class,
        sub_context_route: sub_context_route,
        valid: valid
      }
    )
  end

  def self.get_from_payload(postback_payload)
    if !postback_payload.nil? && postback_payload.class == String
      routes = postback_payload.split(Regexp.union(["/","-",'__']))
      if routes.count > 1
        routes.pop
        return routes.join(".")
      end
    end

    return nil

  end

  def self.get(value)

    if !value.nil? && value.class == String
      $contexts.each do |context|
         if value.start_with?("#{context}_")
            return(
              {
                context: context,
                param: value.sub("#{context}_","")
              }
            )
         end
      end
    end

    return nil

  end

  def delegate_to(route, args={})
    args = {ignore_everything_else:true}.merge(args)
    action_found = false
    route = translate_route(route)
    call_callback(:before_delegate)
    context_route = self.class.router(route, @message.type)
    context_class = context_route[:class]
    sub_context_route = context_route[:sub_context_route]
    unless context_route[:valid]
      logger.write "ERROR: #{context_class.to_s} doesn't exist.", :red
      return false
    end
    logger.write "Delegating to #{route}", :pink
    delegated_context = context_class.new(@user,@message,@reply,route)
    delegated_context.blocks()
    delegated_context.call_callback(:on_delegate)
    unless delegated_context.halted?
      if @run_type == :text_only
        action_found = delegated_context.run_for_text_only({run_blocks_method: false, ignore_everything_else: args[:ignore_everything_else]})
      else
        action_found = delegated_context.run({run_blocks_method: false, ignore_everything_else: args[:ignore_everything_else]})
      end
    end
    # if action_found
      halt(true)
      return true
    # else
    #   return false
    # end
  end

  def change_to(route, params={})
    route = translate_route(route)
    call_callback(:on_exit) unless sub_context?(route) # will_exit? prevents to not execute :on_exit callback when the the contexts changes to a sub_context
    context_route = self.class.router(route, @message.type)
    context_class = context_route[:class]

    unless context_route[:valid]
      logger.write "ERROR: #{context_class.to_s} doesn't exist.", :red
      return false
    else
      call_class_callback(:before_exit) if self.class != context_class # only will be executed if the contexts is changed to another    
      unless self.halted?
        @user.set_context(route, params)
        context = context_class.new(@user,@message,@reply)
        context.blocks()
        context.call_callback(:on_enter)  
      end
    end
  end

  def ask(answer_route=nil, params={}, &block)
    unless answer_route.nil?
      route = (self.parent_context_route != "" and answer_route[0] != "/") ? "../#{answer_route}" : answer_route
      change_to(route, params)
    end

    unless block.nil?
      if answer_route.nil?
        callback :on_enter do
          block.call
        end
      else
        block.call
      end
    end

  end

  def save_current_context
    @user.save_current_context
  end

  def change_to_saved_context
    saved_context = @user.vars[:saved_context]
    unless saved_context.nil?
      @user.delete_previous_context
        change_to(saved_context[:context], saved_context[:params])
    else
      self.exit()
    end
  end

  def exit_answer
    self.exit()
  end

  def keep
    @user.set_context(@current)
  end

  def translate_route(route)
    route = route.to_s
    case route
      when "/", "", nil
        return ""
      when :parent, "../"
        return self.parent_context_route
      else
        if route[0] == "/"
          tmp_route = route.split("/")
          tmp_route.slice!(0)
          return tmp_route.join(".")
        elsif route[0..2] == "../"
          return "#{self.parent_context_route}.#{route[3..]}"
        elsif route [0..1] == "./"
          return "#{self.current_context_route}.#{route[2..]}"      
        elsif !route.index("/").nil?
          return route.gsub("/",".")
        else
          # return "#{@current}.#{route}"
          return "#{self.current_context_route}.#{route}"
        end
    end
  end

  def exit
    call_callback(:on_exit)
    call_class_callback(:before_exit) unless self.class == MainContext
    unless self.halted?
      @user.exit_context
    end
  end

  def exit_context
    self.exit
  end

  def sub_context?(sub_context)
    (sub_context =~ /#{@current.to_s}/) == 0
  end

  def set_nlp_reference(**values) # This is used to send context references to Wit https://wit.ai/docs/http/20170307#context_link
    @user.vars[:nlp_context_ref] = values
  end

  def destroy_nlp_reference
    @user.vars.delete(:nlp_context_ref)
  end

  # Methods to overwrite

  def blocks
    #overwrite this with your routes
  end

  def params
    @user.get_context_params
  end

  def self.base_template(action_group,action, params,returnable, instance)
    template = $context_blocks[action_group.to_sym][action.to_sym] rescue nil
        
    log_string = "  Rendering template: #{File.join("bot","templates",action_group.to_s,"#{action.to_s}.erb")}"    
    log_string = "#{log_string} with params #{params.to_h}" unless params.to_h.empty?    
    logger.write log_string, :pink

    unless template.nil?
      if !returnable
        template.render(instance, params)
      else
        template
      end
    else
      logger.write "  ERROR: Template #{action_group}/#{action}.erb not found.", :red
    end
  end

  def template(action_group,action, params={})
    self.class.base_template(action_group, action, params, false, self)
  end

  # def self.html_template(action_group,action, params={}, instance=nil)
  #   instance = self if instance.nil?
  #   template = $context_html_templates[action_group.to_sym][action.to_sym]
  #   if template.nil?
  #     logger.write "Template bot/templates/#{action_group}/#{action}.rhtml not found.", :red
  #     return ""
  #   else
  #     return template.render(instance, params)
  #   end
  # end

  # def html_template(route,params,instance)
  #     self.class.html_template(action_group, action, params, false, self)
  # end

  def root
    class_name = self.class.to_s
    last_occurence = class_name.rindex("Context") - 1
    class_name[0..last_occurence].underscore
  end

  # Sequences

  def sequences

    #You should overwrite this in the Context

  end

  def start_sequence(stage_route, context_name=nil)
    stage_array = stage_route.to_s.split("/")
    if stage_array.count == 2
      context_name = stage_array[0]
      stage = stage_array[1]
    else
      context_name = self.name
      stage = stage_route
    end
    @user.set_sequence(stage, context_name)
  end

  def stop_sequence(stage_route)
    stage_array = stage_route.to_s.split("/")
    if stage_array.count == 2
      context_name = stage_array[0]
      stage = stage_array[1]
    else
      context_name = self.name
      stage = stage_route
    end
    @user.exit_sequence(stage, context_name)
  end


  def sequence(stage_name, &block)
    @current_sequence_stage = stage_name.to_sym
    sequence = sequence_name()
    @sequences[sequence] = {} if @sequences[sequence].nil?
    block.call
    @current_sequence_stage = nil
  end

  def past(time_elapsed,&block)
    return false if @current_sequence_stage.nil?
    sequence = sequence_name()
    @sequences[sequence][time_elapsed.to_i] = block
  end

  def sequence_name
    return nil if @current_sequence_stage.nil?
    "#{self.name}.#{@current_sequence_stage}"
  end
  

  def self.run_sequence(action)
    logger.write "Running delayed action ##{action.id}|#{action.route} for user ##{action.user.psid}"
    action.user.get_session_vars
    if action.user.platform == "messenger"
      notification = Kogno::Messenger::Notification.new(action.user)
    elsif action.user.platform == "telegram"
      notification = Kogno::Telegram::Notification.new(action.user)
    else
      notification = Kogno::Notification.new(action.user)
    end    
    context = self.router(action.route)[:class].new(action.user,{},notification)
    context.sequences()
    user = action.user
    # context.get_sequences[action.route].sort{|x,y| y<=>x}.each do |past,block|
    if !context.get_sequences[action.route].nil?
      context.get_sequences[action.route].sort.each do |past,block|
        if past > action.last_executed
          execution_time = action.last_hit_at+past
          if  Time.now.utc > execution_time
            block.call      
            notification.send
            user.log_response(notification) if Kogno::Application.config.store_log_in_database
            action.last_executed = past
            action.save
          else
            action.execution_time = execution_time
            action.save
            logger.write "It's not time yet. Execution time at #{execution_time} it will be executed at #{execution_time-Time.now.utc} seconds.", :red
            return false
          end
        end
      end
      logger.write "End of cycle, there is no more in this sequence so this user will be exited from the stage:#{action.route}"
      context.stop_sequence
      return false
    else
      logger.write "Not action found for #{action.route}"
      context.stop_sequence
      return false 
    end 
  end

  def get_sequences
    @sequences
  end

  def memorize_message
    @user.vars[:memory] = @message.data
  end

  def remember_message
    unless @user.vars[:memory].nil?
      @memorized_message = @user.vars[:memory]
      @user.vars.delete(:memory)
    end
  end

  def handle_message_from_memory(platform=nil)
    unless @memorized_message.nil?
      if platform == :telegram
        message = Kogno::Telegram::Message.new(@memorized_message)
      else
        message = Kogno::Messenger::Message.new(@memorized_message)
      end
      message.handle_event()
      @memorized_message = nil
    end
  end

  def change_locale(locale)
    @user.set_locale(locale)
    @message.set_nlp(locale)
    I18n.locale = locale
  end

  def get_default_context_for_command(command)
    default_context = Kogno::Application.config.routes.commands[command.to_sym]
    default_context = Kogno::Application.config.routes.default if default_context.nil?
    return default_context
  end

  def debugger
    {
      blocks: @blocks,
      deep_blocks: @deep_blocks,
      callbacks: @callbacks
    }
  end

  protected 

  def logger_call(action_name, argument, params=[], found=false, deep_action=false)
    sub_context = current_sub_context
    sub_context_string = ".#{sub_context}" unless sub_context.empty?
    argument_string = "(\"#{argument}\")" unless argument.nil?
    deep_action_string = "deep." if deep_action
    params = params.map{|param| param.class == String ? "\"#{param}\"" : param.to_s }.join(", ") if params.class == Kogno::BlockParams
    unless params.nil? || params.empty?
      logger.write "- #{deep_action_string}#{action_name}#{argument_string} => |#{params}|", found ? :green : :white
    else
      logger.write "- #{deep_action_string}#{action_name}#{argument_string}#{deep_action_string}", found ? :green : :white
    end

  end

  def nice_current_route
    current_sub_context = self.current_sub_context()
    unless current_sub_context.empty?
      "#{self.class.name.to_s}.#{current_sub_context}"
    else 
      self.class.name.to_s
    end
  end

end
