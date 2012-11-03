require 'mkmf'

with_ldflags($LDFLAGS + ' -framework Foundation'){ true }

create_makefile('fspath/mac/finder_label_number')
