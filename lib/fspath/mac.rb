require 'fspath'
require 'appscript'

class FSPath
  module Mac
    # Move to trash using finder
    def move_to_trash
      mac_finder_alias.delete
    end

    FINDER_LABEL_COLORS = [nil, :grey, :green, :purple, :blue, :yellow, :red, :orange].freeze
    FINDER_LABEL_COLOR_ALIASES = {:gray => :grey}.freeze
    # Get finder label (one of nil, :orange, :red, :yellow, :blue, :purple, :green and :grey)
    def finder_label
      FINDER_LABEL_COLORS[finder_label_number]
    end
    # Set finder label (:grey is same as :gray, nil or false as :none)
    def finder_label=(color)
      color = FINDER_LABEL_COLOR_ALIASES[color] || color
      index = FINDER_LABEL_COLORS.index(color)
      raise "Unknown label #{color.inspect}" unless index
      self.finder_label_number = index
    end

    # Get spotlight comment
    def spotlight_comment
      mac_finder_alias.comment.get
    end

    # Set spotlight comment
    def spotlight_comment=(comment)
      mac_finder_alias.comment.set(comment.to_s)
    end

    # MacTypes::Alias for path
    def mac_alias
      MacTypes::Alias.path(@path)
    end

    # MacTypes::FileURL for path
    def mac_file_url
      MacTypes::FileURL.path(@path)
    end

    # Finder item for path through mac_alias
    def mac_finder_alias
      Appscript.app('Finder').items[mac_alias]
    end

    # Finder item for path through mac_alias
    def mac_finder_file_url
      Appscript.app('Finder').items[mac_file_url]
    end
  end

  include Mac
end

require 'fspath/mac/finder_label_number'
