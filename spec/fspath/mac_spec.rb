require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fspath/mac'

describe FSPath::Mac do
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
      osxutils_label = case label
      when :grey
        'Gray'
      when nil
        'None'
      else
        "#{label[0].upcase}#{label[1..-1]}"
      end
      system *%W[setlabel -s #{osxutils_label} #{path}]
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
      osxutils_label = IO.popen(%W[hfsdata -L #{path}], &:read).strip

      case osxutils_label
      when 'Gray'
        :grey
      when 'None'
        nil
      else
        osxutils_label.downcase.to_sym
      end
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

  describe '#spotlight_comment' do
    let(:path){ FSPath.temp_file_path }

    it 'returns empty string when comment not set' do
      expect(path.spotlight_comment).to eq('')
    end

    it 'returns string when set to string' do
      string = 'abc'
      system *%W[setfcomment -c #{string} #{path}]

      sleep 0.1

      expect(path.spotlight_comment).to eq(string)
    end

    it 'preserves whitespace' do
      string = " a \n\tb\t\nc\nd\r\nd\n\r"
      system *%W[setfcomment -c #{string} #{path}]

      sleep 0.1

      expect(path.spotlight_comment).to eq(string)
    end

    it 'removes comment when set to empty string' do
      system *%W[setfcomment -c #{} #{path}]

      sleep 0.1

      expect(path.spotlight_comment).to eq('')
    end
  end

  describe '#spotlight_comment=' do
    let(:path){ FSPath.temp_file_path }

    def getfcomment(path)
      IO.popen(['getfcomment', path.to_s], &:read)[0..-2]
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
