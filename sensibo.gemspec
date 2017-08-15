Gem::Specification.new do |gem|
  gem.name = 'sensibo'
  gem.version = '1.2.0'
  gem.summary = 'Ruby implementation of Sensibo API'
  gem.description = 'Ruby implementation of Sensibo API'
  gem.authors = ['Michael Davie']
  gem.email = 'michael.davie@gmail.com'
  gem.files = ['lib/sensibo.rb']
  gem.homepage = 'https://home.sensibo.com/me/api'
  gem.add_runtime_dependency 'httparty'
  gem.required_ruby_version = '2.1.0'
end