Gem::Specification.new do |gem|
  gem.name = 'sensibo'
  gem.version = '1.0.0'
  gem.summary = 'Ruby implementation of Sensibo API'
  gem.description = 'Ruby implementation of Sensibo API'
  gem.authors = ['Michael Davie']
  gem.email = 'michael.davie@gmail.com'
  gem.files = ['lib/sensibo.rb']
  gem.homepage = 'https://home.sensibo.com/me/api'
  gem.add_runtime_dependency 'httparty'
end