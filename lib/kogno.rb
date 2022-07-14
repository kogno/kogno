$VERBOSE = nil
require 'active_record'
require 'core/lib/base_config'
require 'logger'
require 'core/extensions/logger'

Logger.set(:stdout)

module Kogno

  require "active_support/configurable"  
  
  class Application

    include ActiveSupport::Configurable

    config_accessor :sequences do
      Kogno::BaseConfig.new(:time_elapsed_after_last_usage)
    end

    config_accessor :error_notifier do
      Kogno::BaseConfig.new(:slack)
    end

    config_accessor :api do
      Kogno::BaseConfig.new(:enable, :key)
    end

    config_accessor :messenger do
      Kogno::BaseConfig.new(:graph_url, :pages, :webhook_verify_token, :persistent_menu, :welcome_screen_payload, :greeting, :ice_breakers, :stickers, :webhook_route, :whitelisted_domains)
    end

    config_accessor :whatsapp do
      Kogno::BaseConfig.new(:graph_url, :phone_number_id, :access_token, :webhook_verify_token)
    end

    config_accessor :nlp do
      Kogno::BaseConfig.new(:wit, :enable)
    end

    config_accessor :telegram do
      Kogno::BaseConfig.new(:bot_name, :api_url, :token, :webhook_https_server, :webhook_drop_pending_updates, :webhook_route)
    end

    config_accessor :routes do
      Kogno::BaseConfig.new(:default, :post_comment, :inline_query, :chat_activity, :commands, :recurring_notification)
    end

    class << self

      def core_path
        File.expand_path('../../',__FILE__)
      end

      def project_path
        File.expand_path(Dir.pwd)
      end

      def create_project_folders
        tmp = File.join(project_path,"tmp")
        logs = File.join(project_path,"logs")
        Dir.mkdir(tmp,0755) unless File.exist?(tmp)
        Dir.mkdir(logs,0755) unless File.exist?(logs)
      end

      def load_core
        ignore_files = Dir[File.join(core_path,'lib','core','web','inc','*.rb')]
        files_to_load_later = []
        Dir[File.join(core_path,'lib','core','**','*.rb')].each do |required_file|
          if !required_file.include?("lib/messenger/") and !required_file.include?("lib/telegram/") and !required_file.include?("lib/whatsapp/")
            load required_file unless ignore_files.include?(required_file)
          else
            files_to_load_later << required_file
          end
        end

        files_to_load_later.each do |required_file|
            load required_file unless ignore_files.include?(required_file)
        end
      end

      def load_locales
        I18n.load_path = Dir[File.join(self.project_path,'config','locales','*.yml')]
        I18n.config.available_locales = self.config.available_locales
        I18n.default_locale = self.config.default_locale
      end

      def load_app # Load App's files: templates/*, controllers/*, helpers/* and models/*
        $context_blocks = {}
        $context_html_templates = {}
        $contexts = Dir[File.join(self.project_path,'bot','contexts','*.rb')].map{|c| c.split("/").last.sub("_context.rb","")} rescue []
        conversation_file = Dir[File.join(self.project_path,'bot','conversation.rb')]
        app_files = Dir[File.join(self.project_path,'bot','**','*.rb')]
        notification_template_files = Dir[File.join(self.project_path,'bot','**','*.erb')]
        html_template_files = Dir[File.join(self.project_path,'bot','**','*.rhtml')]
        lib_files = Dir[File.join(self.project_path,'lib','**','*.rb')]
        (conversation_file+app_files+notification_template_files+html_template_files+lib_files).each do |required_file|
          if required_file.include?("bot/templates/")
            file_extension = required_file.split(".").last.to_sym
            context = File.dirname(required_file).split("/").last.to_sym
            case file_extension
              when :erb
                action = File.basename(required_file,".erb").to_sym
                $context_blocks[context] = {} if $context_blocks[context].nil?
                # $context_blocks[context][action] = File.read(required_file)
                $context_blocks[context][action] = Tilt.new(required_file, nil, default_encoding: "utf-8")
              when :rhtml
                action = File.basename(required_file,".rhtml").to_sym
                $context_html_templates[context] = {} if $context_html_templates[context].nil?
                $context_html_templates[context][action] = Tilt.new(required_file, nil, default_encoding: "utf-8")
              end
          else
            load required_file
          end
        end
        return true
      end

      def file_path(file)
        if File.exist?(file)        
        else
          File.open(file, "w") {|f| f.write("") }
        end
        return file
      end

    end
  end
end
