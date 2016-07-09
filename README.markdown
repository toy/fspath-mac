# fspath

Better than Pathname

[![Build Status](https://travis-ci.org/toy/fspath-mac.png?branch=master)](https://travis-ci.org/toy/fspath-mac)

### OS X stuff

Move to trash:

    FSPath('a').move_to_trash

Get finder label (one of :none, :orange, :red, :yellow, :blue, :purple, :green and :gray):

    FSPath('a').finder_label

Set finder label (:grey is same as :gray, nil or false as :none):

    FSPath('a').finder_label = :red

Get spotlight comment:

    FSPath('a').spotlight_comment

Set spotlight comment:

    FSPath('a').spotlight_comment = 'a file'

## Copyright

Copyright (c) 2010-2016 Ivan Kuchin. See LICENSE.txt for details.
