
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'x/yarakuzen/version'

Gem::Specification.new do |spec|
  spec.name          = 'x-yarakuzen'
  spec.version       = X::Yarakuzen::VERSION
  spec.authors       = ['shengbo.xu']
  spec.email         = ['to.be.mr.all.rounder@gmail.com']

  spec.summary       = 'This is gem for using yarakuzen(https://www.yarakuzen.com/) easily.'
  spec.description   = ''
  spec.homepage      = 'https://github.com/yamadagenki/x-yarakuzen'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'railties'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'retryable'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rb-readline'

  spec.add_runtime_dependency 'dotenv'
end
