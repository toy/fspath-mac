Dir.chdir File.join(File.dirname(__FILE__), '..') do
  Dir['ext/**/extconf.rb'].each do |extconf|
    Dir.chdir(File.dirname(extconf)) do
      system('ruby extconf.rb') && system('make') or abort "failed compiling #{extconf}"
    end
  end
end

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..', 'ext')
require 'rspec'
