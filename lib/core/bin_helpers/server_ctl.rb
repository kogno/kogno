module Kogno
class ServerCtl
  class << self

    def log_environment_info
      logger.write "Kogno #{Gem.loaded_specs["kogno"].version.version} server starting in #{Kogno::Application.config.environment}", :bright
    end

    def pid_file(service)
      case service
        when 'webhook'
          return Application.file_path(File.join(Application.project_path,"tmp","webhook.pid"))
        when 'sequence'
          return Application.file_path(File.join(Application.project_path,"tmp","sequence.pid"))
        when 'scheduled_messages'  
          return Application.file_path(File.join(Application.project_path,"tmp","scheduled_messages.pid"))
        else
          return 0
      end
      
    end

    def webhook_server_file
      File.join(Application.core_path,"lib/core/web/webhook.rb")
    end

    def save_pid(pid, service)
      File.write(pid_file(service), pid)      
    end

    def delete_pid(service)
      save_pid("",service)
    end

    def get_pid(service)
      File.read(File.join(pid_file(service))).to_i
    end

    def kill_process(pid)
      return false if pid.to_i == 0
      Process.kill("KILL",pid) rescue nil
    end

    def alive?(service)
       pid = get_pid(service)
       return false if pid == 0
       Process.getpgid(pid) rescue false
    end

    def start
      log_environment_info()
      if get_pid('webhook') > 0
        logger.write "Http: daemon already started..", :red
      else
        logger.write "Http: starting daemon..", :green
        system(%{
          RACK_ENV=#{Kogno::Application.config.environment} ruby #{self.webhook_server_file} daemon > /dev/null&
          echo $! > "#{self.pid_file('webhook')}"
        })
      end

      if get_pid('sequence') > 0
        logger.write "Sequence: daemon already started..", :red
      else
        logger.write "Sequence: starting daemon..", :green
        pid = fork do
          Logger.set(:sequences)
          require File.join(Kogno::Application.project_path,'application.rb')
          Sequence.process_all
        end
        save_pid(pid, 'sequence')
      end

      if get_pid('scheduled_messages') > 0
        logger.write "Scheduled Messages: daemon already started..", :red
      else
        logger.write "Scheduled Messages: starting daemon..", :green
        pid = fork do
          Logger.set(:scheduled_messages)
          require File.join(Kogno::Application.project_path,'application.rb')
          ScheduledMessage.process_all
        end
        save_pid(pid, 'scheduled_messages')
      end

    end

    def stop
      sequence_pid = get_pid('sequence')
      kill_process(sequence_pid)
      delete_pid('sequence')

      webhook_pid = get_pid('webhook')
      kill_process(webhook_pid)
      delete_pid('webhook')

      scheduled_messages_pid = get_pid('scheduled_messages')
      kill_process(scheduled_messages_pid)
      delete_pid('scheduled_messages')

      logger.write "STOP", :red
    end

    def status
      alive?('webhook') ? logger.write("Http running | Pid: #{get_pid('webhook')}..", :green) : logger.write("Http stopped", :red)
      alive?('sequence') ? logger.write("Sequences running | Pid: #{get_pid('sequence')}..", :green) : logger.write("Sequence stopped", :red)
      alive?('scheduled_messages') ? logger.write("Scheduled Messages running | Pid: #{get_pid('scheduled_messages')}..", :green) : logger.write("Scheduled Messages stopped", :red)      
    end

    def options(option)
      case option.to_sym
        when :start
          start
        when :stop
          stop
        when :status
          status
        when :restart
          stop
          start
        else
          puts "usage: server stop|start|restart|status"
      end
    end
  end
end
end
