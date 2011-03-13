require 'spec_helper'

module Adrift
  describe Pattern do
    describe "#specialize" do
      let(:attachment) { double('attachment') }

      it "replaces :attachment with the pluralized attachment's name" do
        attachment.stub(name: 'avatar')
        Pattern.new(':attachment').specialize(attachment: attachment).should == 'avatars'
      end

      it "replaces :style with the given style" do
        Pattern.new(':style').specialize(style: :normal).should == 'normal'
      end

      it "replaces :url with the attachment's url for the given style" do
        attachment.stub(:url) do |style|
          case style
          when :original then '/attachment/url'
          when :small    then '/attachment/small/url'
          end
        end
        pattern = Pattern.new(':url')
        pattern.specialize(attachment: attachment, style: :original).should == '/attachment/url'
        pattern.specialize(attachment: attachment, style: :small).should == '/attachment/small/url'
      end

      context "when the model's class is a top-level one" do
        it "replaces :class with  the pluralized model's class name" do
          attachment.stub_chain(:model, :class, :name).and_return('User')
          Pattern.new(':class').specialize(attachment: attachment).should == 'users'
        end

        it "replaces :class_name with the pluralized model's class name" do
          attachment.stub_chain(:model, :class, :name).and_return('User')
          Pattern.new(':class_name').specialize(attachment: attachment).should == 'users'
        end
      end

      context "when the model's class is not a top-level one" do
        it "replaces :class with the pluralized model's class name namespaced" do
          attachment.stub_chain(:model, :class, :name).and_return('App::Models::User')
          Pattern.new(':class').specialize(attachment: attachment).should == 'app/models/users'
        end

        it "replaces :class_name with the pluralized model's class name" do
          attachment.stub_chain(:model, :class, :name).and_return('App::Models::User')
          Pattern.new(':class_name').specialize(attachment: attachment).should == 'users'
        end
      end

      it "replaces :id with the model's id" do
        attachment.stub_chain(:model, :id).and_return(1)
        Pattern.new(':id').specialize(attachment: attachment).should == '1'
      end

      context "when Pattern::Tags::Root.path has been assigned" do
        after { Pattern::Tags::Root.path = nil }

        it "returns Root.path" do
          Pattern::Tags::Root.path = '/root/path'
          Pattern.new(':root').specialize.should == '/root/path'
        end
      end

      context "when Root.path hasn't been assigned" do
        it "returns '.' by default" do
          Pattern.new(':root').specialize.should == '.'
        end
      end

      it "replaces :filename with the attachment's file name" do
        attachment.stub(filename: 'me.png')
        Pattern.new(':filename').specialize(attachment: attachment).should == 'me.png'
      end

      it "replaces :basename with the attachment's file basename" do
        attachment.stub(filename: 'me.png')
        Pattern.new(':basename').specialize(attachment: attachment).should == 'me'
      end

      it "replaces :extension with the attachment's file extension" do
        attachment.stub(filename: 'me.png')
        Pattern.new(':extension').specialize(attachment: attachment).should == 'png'
      end

      it "replaces a tag every time it appears" do
        attachment.stub(name: 'avatar')
        Pattern.new(':attachment/:attachment/:attachment').specialize(attachment: attachment).should == 'avatars/avatars/avatars'
      end

      it "doesn't replace unknown tags" do
        Pattern.new(':unknown_tag').specialize.should == ':unknown_tag'
      end
    end
  end
end
