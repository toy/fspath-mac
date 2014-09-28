require 'fspath'
require 'shellwords'

class FSPath
  module Mac
    # Move to trash
    def move_to_trash
      # actual implementation in extension
    end

    FINDER_LABEL_COLORS = [nil, :grey, :green, :purple, :blue, :yellow, :red, :orange].freeze
    FINDER_LABEL_COLOR_ALIASES = {:gray => :grey}.freeze

    # Get finder label (one of nil, :orange, :red, :yellow, :blue, :purple, :green and :grey)
    def finder_label
      FINDER_LABEL_COLORS[finder_label_number]
    end

    # Set finder label (:grey is same as :gray, nil or false as :none)
    def finder_label=(color)
      index = FINDER_LABEL_COLORS.index(FINDER_LABEL_COLOR_ALIASES[color] || color)
      raise "Unknown label #{color.inspect}" unless index
      self.finder_label_number = index
    end

    # Get spotlight comment
    def spotlight_comment
      with_argv_tell_finder_to 'get comment of (POSIX file (item 1 of argv) as alias)'
    end

    # Set spotlight comment
    def spotlight_comment=(comment)
      with_argv_tell_finder_to 'set comment of (POSIX file (item 1 of argv) as alias) to (item 2 of argv)', comment.to_s
    end

  private

    def with_argv_tell_finder_to(command, *args)
      applescript = <<-APPLESCRIPT
        on run argv
          tell application "Finder" to #{command}
        end run
      APPLESCRIPT
      arguments = [%w[osascript], applescript.lines.map{ |line| ['-e', line.strip] }, expand_path.to_s, *args].flatten
      `#{arguments.shelljoin}`.chomp("\n")
    end
  end

  include Mac
end

require 'fspath/mac/ext'
