require 'mkmf'

with_ldflags($LDFLAGS + ' -framework AppKit'){ true }

create_makefile('fspath/mac/ext')
