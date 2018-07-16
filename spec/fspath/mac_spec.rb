require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fspath/mac'

describe FSPath::Mac do
  describe "mac related" do
    describe "move_to_trash" do
      it "should remove file but not unlink it" do
        @path = FSPath.temp_file_path
        @link = FSPath.temp_file_path
        @link.unlink
        @link.make_link(@path)

        expect(@path.move_to_trash).to be true

        expect(@path).not_to exist
        expect(@link.stat.nlink).to eq(2)
      end
    end

    describe "finder labels" do
      describe "getting" do
        it "should call finder_label_number" do
          @path = FSPath('to_label')

          expect(@path).to receive(:finder_label_number).and_return(0)

          @path.finder_label
        end

        it "should return apporitate label" do
          @path = FSPath('to_label')

          FSPath::FINDER_LABEL_COLORS.each_with_index do |label, index|
            allow(@path).to receive(:finder_label_number).and_return(index)
            expect(@path.finder_label).to eq(label)
          end
        end
      end

      describe "setting" do
        it "should call finder_label_number=" do
          @path = FSPath('to_label')

          expect(@path).to receive(:finder_label_number=)

          @path.finder_label = nil
        end

        describe "index" do
          before do
            @path = FSPath('to_label')
          end

          it "should call label_index.set with apporitate index" do
            FSPath::FINDER_LABEL_COLORS.each_with_index do |label, index|
              expect(@path).to receive(:finder_label_number=).with(index).ordered
              @path.finder_label = label
            end
          end

          it "should accept aliases" do
            FSPath::FINDER_LABEL_COLOR_ALIASES.each do |label_alias, label|
              index = FSPath::FINDER_LABEL_COLORS.index(label)
              expect(@path).to receive(:finder_label_number=).with(index).ordered
              @path.finder_label = label_alias
            end
          end

          it "should set to none when called with nil or false" do
            expect(@path).to receive(:finder_label_number=).with(0).ordered
            @path.finder_label = nil
          end

          it "should raise when called with something else" do
            [true, :shitty, 'hello'].each do |label|
              expect do
                @path.finder_label = label
              end.to raise_error("Unknown label #{label.inspect}")
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
            expect(@path.send(:finder_label_number)).to eq(label_number)
            color = mac_finder_alias_colors[label_index_through_osascript(@path)]
            expect(FSPath::Mac::FINDER_LABEL_COLORS.index(color)).to eq(label_number)
          end
        end
      end
    end

    describe "spotlight comments" do
      it "sets and retrieves spotlight comment" do
        @path = FSPath.temp_file_path

        expect(@path.spotlight_comment).to eq('')

        @path.spotlight_comment = 'abc'
        expect(@path.spotlight_comment).to eq('abc')

        @path.spotlight_comment = 1
        expect(@path.spotlight_comment).to eq('1')

        @path.spotlight_comment = "def\nghi"
        expect(@path.spotlight_comment).to eq("def\nghi")

        @path.spotlight_comment = nil
        expect(@path.spotlight_comment).to eq('')
      end
    end
  end
end
