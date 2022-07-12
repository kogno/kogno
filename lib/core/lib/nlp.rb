require 'wit'
module Kogno
class Nlp

  attr_accessor :wit, :intents, :entities, :traits, :processed, :phrase, :context_reference

  def initialize(phrase=nil,locale=:en, context_reference=nil)
    self.wit = Wit.new(access_token: Nlp.get_wit_token(locale), api_version: Kogno::Application.config.nlp.wit[:api_version])
    self.processed = false
    self.phrase = phrase
    self.context_reference = context_reference
    self.entities = {}
  end

  def self.get_wit_token(locale)
    tokens = Kogno::Application.config.nlp.wit[:apps]
    if !locale.nil? and !tokens[locale.to_sym].nil?
      return tokens[locale.to_sym]
    else # Hash      
      return tokens[:default]
    end
  end

  def set_context_reference(context_reference)
    self.context_reference = context_reference
  end

  def process_phrase(phrase=nil, context_reference=nil)
    if !Kogno::Application.config.nlp.wit[:enable]
      logger.write "NLP Service is not enabled in config/initializers/nlp.rb", :red
      return false
    end

    wit_tries = 0

    phrase = phrase.nil? ? self.phrase : phrase
    context_reference = context_reference.nil? ? self.context_reference : context_reference

    self.processed = true
    if phrase.nil? or phrase.empty?
      {}
    elsif phrase.length > 256
      {}  
    else

      phrase = Spelling::correction(phrase)
      # logger.write "-----", :red
      # logger.write phrase, :red

      wit_output = nil
      loop do
        wit_output = self.wit.message_with_context(phrase, context_reference) rescue :error
        break if wit_output != :error || wit_tries == 3
        logger.debug "Wit error!!!", :red
        wit_tries+=1
        sleep(1)
      end

      self.intents = wit_output["intents"].deep_symbolize_keys! rescue {}
      self.entities = wit_output["entities"].deep_symbolize_keys! rescue {}
      self.traits = wit_output["traits"].deep_symbolize_keys! rescue {}

      logger.debug "  NLP RESOLVED VALUES => #{wit_output}", :light_blue

      self.add_pre_processed_entities()
    end

  end

  def process_phrase_once
    unless self.processed
      self.process_phrase
    end
  end

  def empty_entities?
    self.processed and self.entities.empty?
  end

  def intent(name_only=true)
    final_intent = nil
    intents = (self.intents rescue nil)
    unless intents.nil?
      intents.each do |intent|
        if final_intent.nil?
          final_intent = intent
        elsif intent[:confidence] > final_intent[:confidence]
          final_intent = intent
        end
      end
    end
    if final_intent.nil?
      return nil
    else
      return name_only ? final_intent[:name] : final_intent
    end
  end

  def expression
    self.entities[:expression].first[:value] rescue nil
  end

  def location
    self.entities[:location] rescue []
  end

  def search_query
    self.entities[:search_query] rescue nil
  end

  def local_search_query
    self.entities[:local_search_query] rescue nil
  end


  def dates
    self.entities[:datetime].map{|d| d[:values][0][:value].to_date} rescue []
  end

  def datetime_range

    params = self.entities[:"wit$datetime:datetime"] rescue []

    dates = {
      :from => nil,
      :to => nil
    }

    # case (params.count rescue 0)
    count = params.count rescue 0

    # when 1
    if count == 1
      if params[0][:value].nil?
        dates[:from] = (params[0][:values][0][:from][:value].to_date rescue nil)
        dates[:to] = (params[0][:values][0][:to][:value].to_date rescue nil)
        dates[:to] = dates[:to] - 1.day unless dates[:to].nil? #esto es por que el git al traer rango trae un dia mas
      else
        dates[:from] = (params[0][:value].to_date rescue nil)
        unless self.entities[:duration].nil?
          dates[:to] = get_return_date_from_duration(dates[:from]) unless dates[:from].nil?
        end
      end
      # when 2
    elsif count > 1
      dates[:from] = (params[0][:value].to_date rescue nil)
      dates[:to] = (params[1][:value].to_date rescue nil)
    end

    if ((dates[:from] > dates[:to]) rescue false) #solo para asegurar que la fecha de salida sea anterior a la de llegada
      from_tmp = dates[:from]
      dates[:from] = dates[:to]
      dates[:to] = from_tmp
    end

    return (dates)
  end

  def datetime_range?
    datetime_range = self.datetime_range
    !datetime_range[:from].nil? && !datetime_range[:to].nil?
  end


  def duration_in_days

    multiplier = {"day"=>1,"week"=>7,"month"=>31}
    duration = (self.entities[:duration][0] rescue nil)
    unless duration.nil?
      return(duration[:value]*multiplier[duration[:unit]] rescue 0)
    else
      return nil
    end

  end

  def self.most_confidence(elements)
    if elements.class == Array
      return elements.sort_by{|element| element["confidence"]}.first
    else
      return false
    end
  end

  def add_pre_processed_entities    
    self.entities[:datetime_range] = self.datetime_range if self.datetime_range?
    self.entities[:datetime] = self.entities[:"wit$datetime:datetime"].map{|v| v[:value] || v[:from][:value] rescue nil} unless self.entities[:"wit$datetime:datetime"].nil?
  end

end
end
