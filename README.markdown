[![Check](https://img.shields.io/github/actions/workflow/status/toy/fspath-mac/check.yml?label=check&logo=github)](https://github.com/toy/fspath-mac/actions/workflows/check.yml)
[![Zizmor](https://img.shields.io/github/actions/workflow/status/toy/fspath-mac/zizmor.yml?label=zizmor&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAzNiAzNiI+PHBhdGggZmlsbD0iI0VCMjAyNyIgZD0iTTAgMzZBMzYgMzYgMCAwIDEgMzYgMHYzQTMzIDMzIDAgMCAwIDMgMzZ6Ii8+PHBhdGggZmlsbD0iI0YxOTAyMCIgZD0iTTMgMzZBMzMgMzMgMCAwIDEgMzYgM3YzQTMwIDMwIDAgMCAwIDYgMzZ6Ii8+PHBhdGggZmlsbD0iI0ZGQ0I0QyIgZD0iTTYgMzZBMzAgMzAgMCAwIDEgMzYgNnYzQTI3IDI3IDAgMCAwIDkgMzZ6Ii8+PHBhdGggZmlsbD0iIzVDOTAzRiIgZD0iTTkgMzZBMjcgMjcgMCAwIDEgMzYgOXYzQTI0IDI0IDAgMCAwIDEyIDM2eiIvPjxwYXRoIGZpbGw9IiMyMjY3OTgiIGQ9Ik0xMiAzNkEyNCAyNCAwIDAgMSAzNiAxMnYzQTIxIDIxIDAgMCAwIDE1IDM2eiIvPjxwYXRoIGZpbGw9IiM4NzY3QUMiIGQ9Ik0xNSAzNkEyMSAyMSAwIDAgMSAzNiAxNXYzQTE4IDE4IDAgMCAwIDE4IDM2eiIvPjwvc3ZnPg==)](https://github.com/toy/fspath-mac/actions/workflows/zizmor.yml)

# fspath

Better than Pathname

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

Copyright (c) 2010-2019 Ivan Kuchin. See LICENSE.txt for details.
