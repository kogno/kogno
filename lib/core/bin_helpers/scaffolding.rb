require 'fileutils'
module Kogno
class Scaffolding
  class << self

    def new_project
      project_name = ARGV[1]
      FileUtils.mkdir(project_name)
      FileUtils.cp_r("#{Application.core_path}/scaffolding/new_project/.","./#{project_name}/")
      FileUtils.mkdir("./#{project_name}/config/initializers")
      FileUtils.mkdir("./#{project_name}/bot/templates")
      FileUtils.mkdir("./#{project_name}/bot/templates/main")
      # FileUtils.mkdir("./#{project_name}/bot/extensions")
      # FileUtils.mkdir("./#{project_name}/bot/models")
      FileUtils.mkdir("./#{project_name}/bot/helpers")
      FileUtils.mkdir("./#{project_name}/lib")
      FileUtils.mkdir("./#{project_name}/logs")
      FileUtils.mkdir("./#{project_name}/tmp")
      FileUtils.mkdir("./#{project_name}/web/public")
      FileUtils.mkdir("./#{project_name}/web/views")

      logger.write "\nA new project has been created at ./#{project_name}", :green
      logger.write "Next steps:", :bright
      logger.write "  - cd ./#{project_name}/", :pink
      logger.write "  - bundle install", :pink
      logger.write "  - Configure the database in config/database.yml", :pink
      logger.write "  - kogno install", :pink
    end

    def install
      if !self.test_database
        logger.write "ERROR: check your database configuration in config/database.yml", :red
      else
        self.create_tables
        logger.write "\nNow, you can configure:\n   config/application.rb\n\nAlso some or all these platforms:\n  config/platforms/messenger.rb \n  config/platforms/telegram.rb \n  config/platforms/whatsapp.rb \n  config/nlp.rb\n", :bright        
      end
    end

    def test_database
      require 'core/db'
      ActiveRecord::Base.connection rescue nil
      return ActiveRecord::Base.connected?
    end

    def create_tables
      logger.write "Creating tables..", :bright
      logger.write "   users", :green
      ActiveRecord::Base.connection.execute(%{
        CREATE TABLE IF NOT EXISTS users (
          id int(10) unsigned NOT NULL AUTO_INCREMENT,
          psid varchar(50),
          platform varchar(50),
          psid_from_post_comment varchar(50),
          page_id varchar(50),          
          name varchar(55), 
          first_name varchar(55), 
          last_name varchar(55), 
          timezone varchar(10), 
          locale varchar(5),
          last_usage_at datetime,
          created_at datetime,
          updated_at datetime,
          context varchar(120) DEFAULT NULL,
          context_params text,
          session_vars text,
          last_message_read boolean default false,
          PRIMARY KEY (id),
          UNIQUE KEY psid (psid),
          UNIQUE KEY token (psid_from_post_comment),
          KEY(page_id),
          KEY(platform)
        ) ENGINE=MyISAM
      })

      logger.write "   kogno_sequences", :green
      ActiveRecord::Base.connection.execute(%{
        CREATE TABLE IF NOT EXISTS kogno_sequences(
        	id int(10) unsigned NOT NULL AUTO_INCREMENT,
        	user_id int unsigned,
        	stage varchar(60),
        	context varchar(60),
        	last_executed int default 0,
        	last_hit_at datetime,
        	execution_time datetime default NULL,
        	created_at datetime,
        	updated_at datetime,
        	primary key(id),
        	unique key user_context(user_id, context)
        ) ENGINE=MyISAM
      })

      logger.write "   kogno_chat_logs", :green
      ActiveRecord::Base.connection.execute(%{
        CREATE TABLE IF NOT EXISTS kogno_chat_logs (
          id int(10) unsigned NOT NULL AUTO_INCREMENT,
          user_id int(10) unsigned DEFAULT NULL,
          message_type varchar(32) COLLATE utf8mb4_general_ci DEFAULT NULL,
          body text COLLATE utf8mb4_general_ci,
          context varchar(120) COLLATE utf8mb4_general_ci DEFAULT NULL,
          message varchar(1024) COLLATE utf8mb4_general_ci DEFAULT NULL,
          payload varchar(120) COLLATE utf8mb4_general_ci DEFAULT NULL,
          payload_params varchar(1024) COLLATE utf8mb4_general_ci DEFAULT NULL,
          nlp_entities text COLLATE utf8mb4_general_ci,
          user_vars text COLLATE utf8mb4_general_ci,
          response text,
          new_user boolean default false,
          processed int(1) unsigned DEFAULT 0,
          scheduled boolean default false,
          created_at datetime DEFAULT NULL,
          updated_at datetime DEFAULT NULL,
          PRIMARY KEY (id),
          KEY user_id (user_id)
        ) ENGINE=MyISAM
      })

      logger.write "   kogno_scheduled_messages", :green
      ActiveRecord::Base.connection.execute(%{
        CREATE TABLE IF NOT EXISTS kogno_scheduled_messages(
          id int(10) unsigned NOT NULL AUTO_INCREMENT,
          user_id int(10) unsigned DEFAULT NULL,
          tag varchar(24) default null,
          messages text,
          send_at datetime,
          created_at datetime,
          updated_at datetime,
          PRIMARY KEY (id),
          KEY user_id (user_id),
          KEY tag (tag)
        ) ENGINE=MyISAM
      })

      logger.write "   kogno_matched_messages", :green
      ActiveRecord::Base.connection.execute(%{
        CREATE TABLE IF NOT EXISTS kogno_matched_messages (
          id int(11) unsigned primary key auto_increment,
          user_id int(11) unsigned not null,
          platform_message_id int(11) unsigned default 0,
          created_at datetime,
          updated_at datetime,
          key(user_id),
          key(platform_message_id)
        ) ENGINE=MyISAM 
      })      

      logger.write "   kogno_telegram_chat_groups", :green
      ActiveRecord::Base.connection.execute(%{
        CREATE TABLE IF NOT EXISTS kogno_telegram_chat_groups (
          id int(11) unsigned primary key auto_increment,
          chat_id bigint not null,
          title varchar(256),
          kind enum('group','supergroup','channel'),
          membership boolean,
          perms varchar(1024),
          inviter_user_id int unsigned not null,
          created_at datetime,
          updated_at datetime,
          unique key(chat_id)
        ) ENGINE=MyISAM 
      })

      logger.write "   kogno_long_payloads", :green
      ActiveRecord::Base.connection.execute(%{
        CREATE TABLE IF NOT EXISTS kogno_long_payloads(
          id int(11) unsigned primary key auto_increment,
          token varchar(32),
          payload varchar(64),
          params text,
          unique key token(token),
          created_at datetime,
          updated_at datetime
        ) ENGINE=MyISAM
      })

      logger.write "   kogno_messenger_recurring_notifications", :green
      ActiveRecord::Base.connection.execute(%{
        CREATE TABLE IF NOT EXISTS kogno_messenger_recurring_notifications(
          id int unsigned auto_increment primary key,
          user_id int unsigned,
          token varchar(64),
          frecuency varchar(32),
          expires_at datetime,
          token_status varchar(32),
          timezone varchar(16),
          active boolean,
          key(user_id),
          key(expires_at),
          created_at datetime,
          updated_at datetime
        ) ENGINE=MyISAM 
      })
   

      # logger.write "   Changin database encoding..", :green
      ActiveRecord::Base.connection.execute("ALTER DATABASE #{ActiveRecord::Base.connection.current_database} CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci")
      ActiveRecord::Base.connection.execute("ALTER TABLE users CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
      ActiveRecord::Base.connection.execute("ALTER TABLE users MODIFY session_vars text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
      ActiveRecord::Base.connection.execute("ALTER TABLE kogno_scheduled_messages MODIFY messages text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
  
    end

  end
end
end
