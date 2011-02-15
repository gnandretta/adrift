require 'spec_helper'

module Adrift
  describe Pattern do
    before do 
      @tags = Pattern.tags.dup
      Pattern.tags.clear
    end

    after do
      Pattern.tags.replace(@tags)
    end

    let(:class_tag) { double('class tag', :label => ':class', :specialize => 'my_app/models/users') }
    let(:class_name_tag) { double('class name tag', :label => ':class_name', :specialize => 'users') }
    let(:id_tag) { double('id tag', :label => ':id', :specialize => '1') }

    describe "#specialize" do
      it "replaces a known tag" do
        Pattern.tags << class_tag
        pattern = Pattern.new(':class')
        pattern.specialize.should == 'my_app/models/users'
      end

      it "replaces a known tag every time it appears" do
        Pattern.tags << class_name_tag
        pattern = Pattern.new(':class_name/:class_name/:class_name')
        pattern.specialize.should == 'users/users/users'
      end

      it "doesn't replace unknown tags" do
        pattern = Pattern.new(':unknown_class')
        pattern.specialize.should == ':unknown_class'
      end

      it "replaces several known tags" do
        Pattern.tags << class_name_tag
        Pattern.tags << id_tag
        pattern = Pattern.new(':class_name/:id')
        pattern.specialize.should == 'users/1'
      end

      it "doesn't get confused with unknown tags and other text" do
        Pattern.tags << class_name_tag
        Pattern.tags << id_tag
        pattern = Pattern.new(':class_namesometext:id:unknowntag')
        pattern.specialize.should == 'userssometext1:unknowntag'
      end

      context "when two tag's labels start with the same string" do
        context "and the shortest one was registered first" do
          it "returns the right specialized string" do
            Pattern.tags << class_tag
            Pattern.tags << class_name_tag
            pattern = Pattern.new(':class_name:class')
            pattern.specialize.should == 'usersmy_app/models/users'
            pattern = Pattern.new(':class:class_name')
            pattern.specialize.should == 'my_app/models/usersusers'
          end
        end

        context "and the longest one was registered first" do
          it "returns the right specialized string" do
            Pattern.tags << class_name_tag
            Pattern.tags << class_tag
            pattern = Pattern.new(':class_name:class')
            pattern.specialize.should == 'usersmy_app/models/users'
            pattern = Pattern.new(':class:class_name')
            pattern.specialize.should == 'my_app/models/usersusers'
          end
        end
      end

      context "when there are two tags with the exactly same label" do
        it "uses the most recently registered" do
          repeated_tag = double('class tag 2', :label => ':class', :specialize => 'repeated')
          repeated_tag.specialize.should_not == class_tag.specialize
          Pattern.tags << class_tag
          Pattern.tags << repeated_tag
          Pattern.new(':class').specialize.should == 'repeated'
        end
      end

      it "only asks the tags that appears in the pattern for its specializations" do
        Pattern.tags << class_tag
        Pattern.tags << class_name_tag
        Pattern.tags << id_tag
        pattern = Pattern.new(':class/:id')
        class_tag.should_receive(:specialize).with(1,2,3)
        id_tag.should_receive(:specialize).with(1,2,3)
        class_name_tag.should_not_receive(:specialize)
        pattern.specialize(1,2,3)
      end
    end
  end

  module Pattern::Tags
    describe Attachment do
      let(:tag) { Attachment.new }

      describe "#label" do
        it "returns ':attachment'" do
          tag.label.should == ':attachment'
        end
      end

      describe "#specialize" do
        it "returns the pluralized attachment's name" do
          attachment = double('attachment', :name => 'avatar')
          tag.specialize(:attachment => attachment).should == 'avatars'
        end
      end
    end

    describe Style do
      let(:tag) { Style.new }

      describe "#label" do
        it "returns ':style'" do
          tag.label.should == ':style'
        end
      end

      describe "#specialize" do
        it "returns the given style" do
          tag.specialize(:style => :normal).should == 'normal'
        end
      end
    end

    describe Url do
      let(:tag) { Url.new }

      describe "#label" do
        it "returns ':url'" do
          tag.label.should == ':url'
        end
      end

      describe "#specialize" do
        it "returns the attachment's url" do
          attachment = double('attachment', :url => '/attachment/url')
          tag.specialize(:attachment => attachment).should == '/attachment/url'
        end
      end
    end

    describe Class do
      let(:tag) { Class.new }

      describe "#label" do
        it "returns ':class'" do
          tag.label.should == ':class'
        end
      end

      describe "#specialize" do
        context "when the model's class is a top-level one" do
          it "returns the pluralized model's class name" do
            attachment = double('attachment')
            attachment.stub_chain(:model, :class, :name).and_return('User')
            tag.specialize(:attachment => attachment).should == 'users'
          end
        end

        context "when the model's class is not a top-level one" do
          it "returns the pluralized model's class name namespaced" do
            attachment = double('attachment')
            attachment.stub_chain(:model, :class, :name).and_return('App::Models::User')
            tag.specialize(:attachment => attachment).should == 'app/models/users'
          end
        end
      end
    end

    describe ClassName do
      let(:tag) { ClassName.new }

      describe "#label" do
        it "returns ':class_name'" do
          tag.label.should == ':class_name'
        end
      end

      describe "#specialize" do
        context "when the model's class is a top-level one" do
          it "returns the pluralized model's class name" do
            attachment = double('attachment')
            attachment.stub_chain(:model, :class, :name).and_return('User')
            tag.specialize(:attachment => attachment).should == 'users'
          end
        end

        context "when the model's class is not a top-level one" do
          it "returns the pluralized model's class name" do
            attachment = double('attachment')
            attachment.stub_chain(:model, :class, :name).and_return('App::Models::User')
            tag.specialize(:attachment => attachment).should == 'users'
          end
        end
      end
    end

    describe Id do
      let(:tag) { Id.new }

      describe "#label" do
        it "returns ':id'" do
          tag.label.should == ':id'
        end
      end

      describe "#specialize" do
        it "returns the model's id" do
          attachment = double('attachment')
          attachment.stub_chain(:model, :id).and_return(1)
          tag.specialize(:attachment => attachment).should == '1'
        end
      end
    end

    describe Root do
      let(:tag) { Root.new }

      describe "#label" do
        it "returns ':root'" do
          tag.label.should == ':root'
        end
      end

      describe "#specialize" do
        context "when Root.path has been assigned" do
          after { Root.path = nil }

          it "returns Root.path" do
            Root.path = '/root/path'
            tag.specialize.should == '/root/path'
          end
        end

        context "when Root.path hasn't been assigned" do
          it "returns '.' by default" do
            tag.specialize.should == '.'
          end
        end
      end
    end

    describe Filename do
      let(:tag) { Filename.new }

      describe "#label" do
        it "returns ':filename'" do
          tag.label.should == ':filename'
        end
      end

      describe "#specialize" do
        it "returns the attachment's filename" do
          attachment = double('attachment', :filename => 'me.png')
          tag.specialize(:attachment => attachment).should == 'me.png'
        end
      end
    end

    describe Basename do
      let(:tag) { Basename.new }

      describe "#label" do
        it "returns ':basename'" do
          tag.label.should == ':basename'
        end
      end

      describe "#specialize" do
        it "returns the attachment's file basename" do
          attachment = double('attachment', :filename => 'me.png')
          tag.specialize(:attachment => attachment).should == 'me'
        end
      end
    end

    describe Extension do
      let(:tag) { Extension.new }

      describe "#label" do
        it "returns ':extension'" do
          tag.label.should == ':extension'
        end
      end

      describe "#specialize" do
        it "returns the attachment's file extension" do
          attachment = double('attachment', :filename => 'me.png')
          tag.specialize(:attachment => attachment).should == 'png'
        end
      end
    end
  end
end
