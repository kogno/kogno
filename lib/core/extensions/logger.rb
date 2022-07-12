class Logger  

  def write(str, color=nil)
    if color.nil?
      self.info(str)
    else
      self.info(Logger::colorize(str, color.to_sym))
    end
  end

  def write_json(json,color=nil)
    write(JSON.pretty_generate(json),color)
  end

  def debug(str,color=nil)
    write(str,color) if Kogno::Application.config.environment == :development
  end

  def debug_json(json,color=nil)
     write(JSON.pretty_generate(json),color) if Kogno::Application.config.environment == :development
  end
  

  class << self

    def set(daemon)
      case daemon
        when :webhook
          $logger = Logger.new(File.join(Kogno::Application.project_path,'logs','http.log'))
        when :sequences
          $logger = Logger.new(File.join(Kogno::Application.project_path,'logs','sequences.log'))
        when :scheduled_messages
          $logger = Logger.new(File.join(Kogno::Application.project_path,'logs','scheduled_messages.log'))  
        else
          $logger = Logger.new(STDOUT)
      end

      # logger.datetime_format = ""
      $logger.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end

      ActiveRecord::Base.logger = $logger
    end


    def colors
      @colors ||= {
        bright: 1,
        blue: 34,
        green: 32,
        light_blue: 36,
        pink: 35,
        red: 31,
        white: 256,
        yellow: 33
      }
    end

    def colorize(str, color_code)
      "\e[#{colors[color_code]}m#{str}\e[0m"
    end

  end

end

def logger
 $logger
end
