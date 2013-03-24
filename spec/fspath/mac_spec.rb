require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fspath/mac'

describe FSPath::Mac do
  describe "mac related" do
    describe "move_to_trash" do
      it "should call delete command using with_argv_tell_finder_to" do
        @path = FSPath('to_delete')

        @path.should_receive(:with_argv_tell_finder_to).with('move (POSIX file (item 1 of argv) as alias) to trash')

        @path.move_to_trash
      end
    end

    describe "finder labels" do
      describe "getting" do
        it "should call finder_label_number" do
          @path = FSPath('to_label')

          @path.should_receive(:finder_label_number).and_return(0)

          @path.finder_label
        end

        it "should return apporitate label" do
          @path = FSPath('to_label')

          FSPath::FINDER_LABEL_COLORS.each_with_index do |label, index|
            @path.stub!(:finder_label_number).and_return(index)
            @path.finder_label.should == label
          end
        end
      end

      describe "setting" do
        it "should call finder_label_number=" do
          @path = FSPath('to_label')

          @path.should_receive(:finder_label_number=)

          @path.finder_label = nil
        end

        describe "index" do
          before do
            @path = FSPath('to_label')
          end

          it "should call label_index.set with apporitate index" do
            FSPath::FINDER_LABEL_COLORS.each_with_index do |label, index|
              @path.should_receive(:finder_label_number=).with(index).ordered
              @path.finder_label = label
            end
          end

          it "should accept aliases" do
            FSPath::FINDER_LABEL_COLOR_ALIASES.each do |label_alias, label|
              index = FSPath::FINDER_LABEL_COLORS.index(label)
              @path.should_receive(:finder_label_number=).with(index).ordered
              @path.finder_label = label_alias
            end
          end

          it "should set to none when called with nil or false" do
            @path.should_receive(:finder_label_number=).with(0).ordered
            @path.finder_label = nil
          end

          it "should raise when called with something else" do
            [true, :shitty, 'hello'].each do |label|
              proc do
                @path.finder_label = label
              end.should raise_error("Unknown label #{label.inspect}")
            end
          end
        end
      end

      describe "number" do
        def label_index_through_osascript(path)
          applescript = <<-APPLESCRIPT
            on run argv
              tell application "Finder" to get label index of (POSIX file (item 1 of argv) as alias)
            end run
          APPLESCRIPT
          arguments = [%w[osascript], applescript.lines.map{ |line| ['-e', line.strip] }, path.to_s].flatten
          `#{arguments.shelljoin}`.to_i
        end

        it "should set label" do
          @path = FSPath.temp_file_path

          mac_finder_alias_colors = [nil, :orange, :red, :yellow, :blue, :purple, :green, :grey]
          8.times do |label_number|
            @path.send(:finder_label_number=, label_number)
            @path.send(:finder_label_number).should == label_number
            color = mac_finder_alias_colors[label_index_through_osascript(@path)]
            FSPath::Mac::FINDER_LABEL_COLORS.index(color).should == label_number
          end
        end
      end
    end

    describe "spotlight comments" do
      describe "getting" do
        it "should call comment get using with_argv_tell_finder_to" do
          @path = FSPath(__FILE__)

          @path.should_receive(:with_argv_tell_finder_to).with('get comment of (POSIX file (item 1 of argv) as alias)')

          @path.spotlight_comment.should == @comment_text
        end
      end

      describe "setting" do
        it "should call comment set using with_argv_tell_finder_to" do
          @path = FSPath(__FILE__)

          @path.should_receive(:with_argv_tell_finder_to).with('set comment of (POSIX file (item 1 of argv) as alias) to (item 2 of argv)', 'abc')

          @path.spotlight_comment = 'abc'
        end
      end

      describe "getting" do
        it "should call comment get using with_argv_tell_finder_to" do
          @path = FSPath.temp_file_path

          @path.spotlight_comment.should == ''

          @path.spotlight_comment = 'abc'
          @path.spotlight_comment.should == 'abc'

          @path.spotlight_comment = 1
          @path.spotlight_comment.should == '1'

          @path.spotlight_comment = "def\nghi"
          @path.spotlight_comment.should == "def\nghi"

          @path.spotlight_comment = nil
          @path.spotlight_comment.should == ''
        end
      end
    end
  end
end
