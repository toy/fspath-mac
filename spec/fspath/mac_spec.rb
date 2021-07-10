require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fspath/mac'

describe FSPath::Mac do
  def osascript_args(script)
    ['osascript'] + script.split("\n").flat_map{ |line| ['-e', line.strip] }
  end

  FINDER_LABELS = [nil, :orange, :red, :yellow, :blue, :purple, :green, :grey]

  describe '#move_to_trash' do
    let(:path){ FSPath.temp_file_path }
    let(:link){ FSPath.temp_file_path }

    it 'removes file but does not unlink it' do
      link.unlink
      link.make_link(path)

      expect(path.move_to_trash).to be true

      expect(path).not_to exist
      expect(link.stat.nlink).to eq(2)
    end
  end

  describe '#finder_label' do
    let(:path){ FSPath.temp_file_path }

    def set_label(path, label)
      label_index = FINDER_LABELS.index(label)
      script = <<-APPLESCRIPT
        on run argv
          tell application "Finder" to set label index of ((POSIX file (item 1 of argv)) as alias) to ((item 2 of argv) as integer)
        end
      APPLESCRIPT
      system *osascript_args(script), path.to_s, label_index.to_s, out: '/dev/null'
    end

    FSPath::FINDER_LABEL_COLORS.each_with_index do |label, index|
      it "returns #{label.inspect} label" do
        set_label(path, label)

        expect(path.finder_label).to eq(label)
      end
    end
  end

  describe '#finder_label=' do
    let(:path){ FSPath.temp_file_path }

    def get_label(path)
      script = <<-APPLESCRIPT
        on run argv
          tell application "Finder" to return label index of ((POSIX file (item 1 of argv)) as alias)
        end
      APPLESCRIPT
      label_index = IO.popen(osascript_args(script) + [path.to_s], &:read).to_i
      FINDER_LABELS[label_index]
    end

    FSPath::FINDER_LABEL_COLORS.each_with_index do |label, index|
      it "accepts #{label.inspect} label" do
        path.finder_label = label

        expect(get_label(path)).to eq(label)
      end
    end

    FSPath::FINDER_LABEL_COLOR_ALIASES.each do |label_alias, label|
      it "accepts #{label_alias} alias" do
        path.finder_label = label_alias

        expect(get_label(path)).to eq(label)
      end
    end

    it 'raises when called with unknown label' do
      [true, :shitty, 'hello'].each do |label|
        expect do
          path.finder_label = label
        end.to raise_error("Unknown label #{label.inspect}")
      end
    end
  end

  describe '#spotlight_comment', skip: ENV['TRAVIS'] do
    let(:path){ FSPath.temp_file_path }

    def setfcomment(path, comment)
      script = <<-APPLESCRIPT
        on run argv
          tell application "Finder" to set comment of ((POSIX file (item 1 of argv)) as alias) to (item 2 of argv)
        end
      APPLESCRIPT
      system *osascript_args(script), path.to_s, comment, out: '/dev/null'
    end

    it 'returns empty string when comment not set' do
      expect(path.spotlight_comment).to eq('')
    end

    it 'returns string when set to string' do
      comment = 'abc'
      setfcomment(path, comment)

      sleep 0.1

      expect(path.spotlight_comment).to eq(comment)
    end

    it 'preserves whitespace' do
      comment = " a \n\tb\t\nc\nd\r\nd\n\r"
      setfcomment(path, comment)

      sleep 0.1

      expect(path.spotlight_comment).to eq(comment)
    end

    it 'removes comment when set to empty string' do
      comment = ''
      setfcomment(path, comment)

      sleep 0.1

      expect(path.spotlight_comment).to eq(comment)
    end
  end

  describe '#spotlight_comment=', skip: ENV['TRAVIS'] do
    let(:path){ FSPath.temp_file_path }

    def getfcomment(path)
      script = <<-APPLESCRIPT
        on run argv
          tell application "Finder" to return comment of ((POSIX file (item 1 of argv)) as alias)
        end
      APPLESCRIPT
      IO.popen(osascript_args(script) + [path.to_s], &:read)[0..-2]
    end

    it 'returns string when set to string' do
      string = 'abc'
      path.spotlight_comment = string
      expect(getfcomment(path)).to eq(string)
    end

    it 'preserves whitespace' do
      string = " a \n\tb\t\nc\nd\r\nd\n\r"
      path.spotlight_comment = string
      expect(getfcomment(path)).to eq(string)
    end

    it 'returns stringified when set to number' do
      path.spotlight_comment = 1
      expect(getfcomment(path)).to eq('1')
    end

    it 'removes comment when set to nil' do
      path.spotlight_comment = nil
      expect(getfcomment(path)).to eq('')
    end
  end
end
