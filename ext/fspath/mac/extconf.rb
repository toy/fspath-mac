require 'mkmf'

with_ldflags($LDFLAGS + ' -framework AppKit'){ true }

create_makefile('fspath/mac/ext')

# fix Makefile not containing rule for .m
makefile = File.read('Makefile')
if makefile && makefile['.c.o:'] && !makefile['.m.o:']
  File.open('Makefile', 'w') do |f|
    f << makefile.sub('.c.o:', '.m.o:')
  end
end
