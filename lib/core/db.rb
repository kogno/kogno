  db_configuration_file = File.join(Kogno::Application.project_path,'config', 'database.yml')
  db_configuration = YAML.load(File.read(db_configuration_file))

  def db_connect(db_configuration)
    ActiveRecord::Base.establish_connection(db_configuration)
  end

  db_connect(db_configuration)
