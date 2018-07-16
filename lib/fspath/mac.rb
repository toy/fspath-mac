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
      # actual implementation in extension
    end

    # Set spotlight comment
    def spotlight_comment=(comment)
      # actual implementation in extension
    end
  end

  include Mac
end

require 'fspath/mac/ext'
