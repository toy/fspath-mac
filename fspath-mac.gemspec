# encoding: UTF-8

Gem::Specification.new do |s|
  s.name        = 'fspath-mac'
  s.version     = '3.2.0'
  s.summary     = %q{FSPath methods for mac (move_to_trash, color labeling, spotlight comments, …)}
  s.homepage    = "http://github.com/toy/#{s.name}"
  s.authors     = ['Ivan Kuchin']
  s.license     = 'MIT'

  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extensions    = `git ls-files -- ext/**/extconf.rb`.split("\n")
  s.require_paths = %w[lib]

  s.add_dependency 'fspath', '>= 2', '< 4'
  s.add_development_dependency 'rspec', '~> 3.0'
end
