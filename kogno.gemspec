Gem::Specification.new do |s|
  s.name        = 'kogno'
  s.version     = '1.0.1.3'
  s.executables << 'kogno'
  s.date        = '2020-06-27'
   s.summary     = "Kogno Framework"
  s.description = "Kogno is an open source framework running on the Ruby programming language for developing conversational applications."
  s.required_ruby_version = '>= 2.7.0'
  s.required_rubygems_version = '>= 1.8.11'
  
  s.authors     = ["Martín Acuña Lledó"]
  s.email       = 'macuna@gmail.com'
  s.files       = ["lib/kogno.rb","lib/boot.rb"]
  s.files       += Dir['lib/core/**/*']
  s.files       += Dir['scaffolding/**/*']
  s.homepage    = 'https://kogno.io'
  s.metadata    = { 
    "documentation_uri" => "https://docs.kogno.io",
    "source_code_uri" => "https://github.com/kogno/kogno" 
  }
  s.add_runtime_dependency 'activerecord', '6.1.5'
  s.add_runtime_dependency 'actionview', '6.1.5'
  s.add_runtime_dependency 'sinatra', '2.2.0'
  s.add_runtime_dependency 'sinatra-contrib'
  s.add_runtime_dependency 'tilt', '2.0.10'
  s.add_runtime_dependency 'sinatra-cross_origin', '0.4.0'
  s.add_runtime_dependency 'wit', '6.0.0'
  s.add_runtime_dependency 'fileutils'
  s.license       = 'MIT'
end

