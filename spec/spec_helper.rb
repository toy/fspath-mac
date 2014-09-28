Dir.chdir File.expand_path('../..', __FILE__) do # chdir to project root
  Dir['ext/**/extconf.rb'].each do |extconf|
    Dir.chdir(File.dirname(extconf)) do
      system('ruby extconf.rb') && system('make') or abort "failed compiling #{extconf}"
    end
  end
end

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..', 'ext')
require 'rspec'
