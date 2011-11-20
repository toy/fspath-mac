require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fspath/mac'

describe FSPath::Mac do
  describe "mac related" do
    describe "move_to_trash" do
      it "should call delete on mac_finder_alias" do
        @path = FSPath('to_delete')
        @finder_alias = mock(:finder_alias)

        @path.should_receive(:mac_finder_alias).and_return(@finder_alias)
        @finder_alias.should_receive(:delete)

        @path.move_to_trash
      end
    end

    describe "finder labels" do
      describe "getting" do
        it "should call label_index.get on mac_finder_alias" do
          @path = FSPath('to_label')
          @finder_alias = mock(:finder_alias)
          @label_index = mock(:label_index)

          @path.should_receive(:mac_finder_alias).and_return(@finder_alias)
          @finder_alias.should_receive(:label_index).and_return(@label_index)
          @label_index.should_receive(:get).and_return(0)

          @path.finder_label
        end

        it "should return apporitate label" do
          @path = FSPath('to_label')
          @finder_alias = mock(:finder_alias)
          @label_index = mock(:label_index)

          @path.stub!(:mac_finder_alias).and_return(@finder_alias)
          @finder_alias.stub!(:label_index).and_return(@label_index)

          FSPath::FINDER_LABEL_COLORS.each_with_index do |label, index|
            @label_index.stub!(:get).and_return(index)
            @path.finder_label.should == label
          end
        end
      end

      describe "setting" do
        it "should call label_index.set on mac_finder_alias" do
          @path = FSPath('to_label')
          @finder_alias = mock(:finder_alias)
          @label_index = mock(:label_index)

          @path.should_receive(:mac_finder_alias).and_return(@finder_alias)
          @finder_alias.should_receive(:label_index).and_return(@label_index)
          @label_index.should_receive(:set)

          @path.finder_label = nil
        end

        describe "index" do
          before do
            @path = FSPath('to_label')
            @finder_alias = mock(:finder_alias)
            @label_index = mock(:label_index)

            @path.stub!(:mac_finder_alias).and_return(@finder_alias)
            @finder_alias.stub!(:label_index).and_return(@label_index)
          end

          it "should call label_index.set with apporitate index" do
            FSPath::FINDER_LABEL_COLORS.each_with_index do |label, index|
              @label_index.should_receive(:set).with(index).ordered
              @path.finder_label = label
            end
          end

          it "should accept aliases" do
            FSPath::FINDER_LABEL_COLOR_ALIASES.each do |label_alias, label|
              index = FSPath::FINDER_LABEL_COLORS.index(label)
              @label_index.should_receive(:set).with(index).ordered
              @path.finder_label = label_alias
            end
          end

          it "should set to none when called with nil or false" do
            [nil, false].each do |label|
              @label_index.should_receive(:set).with(0).ordered
              @path.finder_label = label
            end
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
    end

    describe "spotlight comments" do
      describe "getting" do
        it "should call comment.get on mac_finder_alias" do
          @path = FSPath(__FILE__)
          @finder_alias = mock(:finder_alias)
          @comment = mock(:comment)
          @comment_text = mock(:comment_text)

          @path.should_receive(:mac_finder_alias).and_return(@finder_alias)
          @finder_alias.should_receive(:comment).and_return(@comment)
          @comment.should_receive(:get).and_return(@comment_text)

          @path.spotlight_comment.should == @comment_text
        end
      end

      describe "setting" do
        it "should call comment.set on mac_finder_alias" do
          @path = FSPath(__FILE__)
          @finder_alias = mock(:finder_alias)
          @comment = mock(:comment)
          @comment_text = mock(:comment_text)

          @path.should_receive(:mac_finder_alias).and_return(@finder_alias)
          @finder_alias.should_receive(:comment).and_return(@comment)
          @comment.should_receive(:set).with(@comment_text.to_s)

          @path.spotlight_comment = @comment_text
        end
      end
    end

    describe "appscript objects" do
      before do
        @file_path = File.expand_path(__FILE__)
      end

      describe "mac_alias" do
        it "should return instance of MacTypes::Alias" do
          FSPath(@file_path).mac_alias.should be_kind_of(MacTypes::Alias)
        end

        it "should point to same path" do
          FSPath(@file_path).mac_alias.path.should == @file_path
        end
      end

      describe "mac_file_url" do
        it "should return instance of MacTypes::FileURL" do
          FSPath(@file_path).mac_file_url.should be_kind_of(MacTypes::FileURL)
        end

        it "should point to same path" do
          FSPath(@file_path).mac_file_url.path.should == @file_path
        end
      end

      describe "mac_finder_alias" do
        it "should return same ref" do
          FSPath(@file_path).mac_finder_alias.should == Appscript.app('Finder').items[FSPath(@file_path).mac_alias]
        end
      end

      describe "mac_finder_file_url" do
        it "should return same ref" do
          FSPath(@file_path).mac_finder_file_url.should == Appscript.app('Finder').items[FSPath(@file_path).mac_file_url]
        end
      end
    end
  end
end
