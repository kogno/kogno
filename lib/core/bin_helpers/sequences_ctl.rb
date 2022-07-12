module Kogno
class SequencesCtl
  class << self

    def pid_file
      Application.file_path(File.join(Application.project_path,"tmp","sequence.pid"))
    end

    def log_environment_info
      logger.write "Kogno #{Gem.loaded_specs["kogno"].version.version} sequences server starting in #{Kogno::Application.config.environment}", :bright
    end

    def save_pid(pid)
      File.write(pid_file, pid)
    end

    def delete_pid
      save_pid("")
    end

    def get_pid
      File.read(File.join(pid_file)).to_i
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
      if get_pid > 0 && alive?
        logger.write "Error: It has already started..", :red
      else 
        log_environment_info()     
        logger.write "START", :green
        pid = fork do
          Logger.set(:sequences)
          require File.join(Kogno::Application.project_path,'application.rb')
          Sequence.process_all
        end
        save_pid(pid)
      end
    end

    def fg
      log_environment_info()
      if get_pid > 0 && alive?
        logger.write "Error: It has already started..", :red
      else        
        require File.join(Kogno::Application.project_path,'application.rb')
        Sequence.process_all
      end
    end

    def stop
      pid = get_pid
      kill_process(pid)
      delete_pid
      logger.write "STOP", :red
    end

    def status
      if alive?
        logger.write "Running | Pid: #{get_pid}..", :green
      else
        logger.write "Stopped", :red
      end
    end

    def options(option)
      case option.to_s.to_sym
        when :start
          start
        when :stop
          stop
        when :fg
          fg
        when :status
          status
        when :restart
          stop
          start
        else
          puts "usage: sequences stop|start|restart|status|fg"
      end
    end
  end
end
end
