module Kogno

  Dir[File.join(Application.project_path,'config','*.rb')].each do |required_file|
    require required_file
  end

  Dir[File.join(Application.project_path,'config','platforms','*.rb')].each do |required_file|
    require required_file
  end

  Dir[File.join(Application.project_path,'config','initializers','*.rb')].each do |required_file|
    require required_file
  end

end