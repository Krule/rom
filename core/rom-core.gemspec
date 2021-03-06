require File.expand_path('../lib/rom/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'rom-core'
  gem.summary       = 'Ruby Object Mapper'
  gem.description   = 'Persistence and mapping toolkit for Ruby'
  gem.author        = 'Piotr Solnica'
  gem.email         = 'piotr.solnica+oss@gmail.com'
  gem.homepage      = 'http://rom-rb.org'
  gem.require_paths = ['lib']
  gem.version       = ROM::Core::VERSION.dup
  gem.files         = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*']
  gem.license       = 'MIT'

  gem.add_runtime_dependency 'concurrent-ruby', '~> 1.0'
  gem.add_runtime_dependency 'dry-container', '~> 0.6'
  gem.add_runtime_dependency 'dry-equalizer', '~> 0.2'
  gem.add_runtime_dependency 'dry-types', '~> 0.11', '>= 0.11.1'
  gem.add_runtime_dependency 'dry-core', '~> 0.3'
  gem.add_runtime_dependency 'dry-initializer', '~> 1.3'
  gem.add_runtime_dependency 'rom-mapper', '~> 1.0.0.beta'

  gem.add_development_dependency 'rake', '~> 10.3'
  gem.add_development_dependency 'rspec', '~> 3.5'
end
