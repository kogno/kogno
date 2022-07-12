module Kogno
class WebhookCtl
  class << self

    def pid_file
      Application.file_path(File.join(Application.project_path,"tmp","webhook.pid"))
    end

    def log_environment_info
      logger.write "Kogno #{Gem.loaded_specs["kogno"].version.version} http server starting in #{Kogno::Application.config.environment}", :bright
    end

    def server_file
      File.join(Application.core_path,"lib/core/web/webhook.rb")
    end

    def save_pid(pid)
      File.write(self.pid_file, pid)
    end

    def delete_pid
      save_pid("")
    end

    def get_pid
      File.read(File.join(self.pid_file)).to_i
    end

    def kill_process(pid)
      return false if pid.to_i == 0
      Process.kill("KILL",pid) rescue nil
    end

    def alive?
      pid = get_pid
      return false if pid == 0
      Process.getpgid(pid) rescue false
    end

    def start
      log_environment_info()
      if get_pid > 0 && alive?
        logger.write "Error: It has already started..", :red
      else        
        system(%{
          RACK_ENV=#{Kogno::Application.config.environment} ruby #{self.server_file} daemon > /dev/null&
          echo $! > "#{self.pid_file}"
        })
        logger.write "START", :green
      end
    end

    def fg
      log_environment_info()
      if get_pid > 0 && alive?
        logger.write "Error: It has already started..", :red
      else
        system("RACK_ENV=#{Kogno::Application.config.environment} ruby #{self.server_file}")
      end
    end

    def stop
      pid = self.get_pid
      self.kill_process(pid)
      self.delete_pid
      logger.write "STOP", :red
    end

    def status
      if alive?
        logger.write "Running | Pid: #{self.get_pid}..", :green
      else
        logger.write "Stopped", :red
      end
    end

    def options(option)
      case option.to_s.to_sym
        when :start
          self.start
        when :stop
          self.stop
        when :restart
          self.stop
          self.start
        when :status
          self.status
        when :fg
          self.fg
        else
          puts "usage: http stop|start|restart|status|fg"
      end
    end
  end
end
end
