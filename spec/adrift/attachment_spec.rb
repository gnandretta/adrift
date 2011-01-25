require 'spec_helper'

module Adrift
  shared_examples_for "any attachment" do
    describe "#empty?" do
      context "when a file has been assigned" do
        it "returns true" do
          attachment.assign(double('up file', :original_filename => 'new_me.png'))
          attachment.should_not be_empty
        end
      end
    end

    describe "#assign" do
      let(:up_file) { double('up file') }

      it "updates the attachment's filename in the model" do
        up_file.stub(:original_filename => 'new_me.png')
        attachment.assign(up_file)
        user.avatar_filename.should == 'new_me.png'
      end

      it "replaces the filename's non alphanumeric characters with '_' (except '.')" do
        up_file.stub(:original_filename => 'my awesome-avatar!.png')
        attachment.assign(up_file)
        attachment.filename.should == 'my_awesome_avatar_.png'
      end
    end
  end

  describe Attachment, "instantiation" do
    let(:user) { user_double }
    let(:attachment) { Attachment.new(:avatar, user) }

    describe "#name" do
      it "returns the attachment's name" do
        attachment.name.should == :avatar
      end
    end

    describe "#model" do
      it "returns the model to which the attachment belongs" do
        attachment.model.should == user
      end
    end
  end

  describe Attachment, "when is empty" do
    let(:user) { user_double(:avatar_filename => nil) }
    let(:attachment) { Attachment.new(:avatar, user) }

    it_behaves_like "any attachment"

    describe "#empty?" do
      it "returns true" do
        attachment.should be_empty
      end
    end

    describe "#url" do
      it "returns a default url" do
        attachment.url.should == '/images/missing.png'
      end

      it "builds the default url from a pattern if there's one" do
        attachment.default_url = '/images/:class_name/missing.png'
        attachment.url.should == '/images/users/missing.png'
      end

      it "accepts a style" do
        attachment.default_url = '/images/:class_name/missing_:style.png'
        attachment.url(:small).should == '/images/users/missing_small.png'
      end

      it "uses a default style if there isn't one" do
        attachment.default_style = :normal
        attachment.default_url = '/images/:class_name/missing_:style.png'
        attachment.url.should == '/images/users/missing_normal.png'
      end

      it "assumes an ':original' default style" do
        attachment.default_url = '/images/:class_name/missing_:style.png'
        attachment.url.should == '/images/users/missing_original.png'
      end
    end

    describe "#path" do
      it "returns nil" do
        attachment.path.should be_nil
      end

      it "accepts a style" do
        attachment.path(:small).should be_nil
      end
    end
  end

  describe Attachment, "when isn't empty" do
    let(:user) { user_double(:id => 1, :avatar_filename => 'me.png') }
    let(:attachment) { Attachment.new(:avatar, user) }

    it_behaves_like "any attachment"

    describe "#empty?" do
      it "returns false" do
        attachment.should_not be_empty
      end
    end

    describe "#url" do
      it "builds its url from a default pattern" do
        attachment.url.should == '/system/attachments/users/1/avatars/me.png'
      end

      it "builds its url from a pattern if there's one" do
        attachment.url = '/:class_name/:id/:attachment/:filename'
        attachment.url.should == '/users/1/avatars/me.png'
      end

      it "accepts a style" do
        attachment.url = '/:class_name/:id/:attachment/:style/:filename'
        attachment.url(:small).should == '/users/1/avatars/small/me.png'
      end

      it "uses a default style if there isn't one" do
        attachment.default_style = :normal
        attachment.url = '/:class_name/:id/:attachment/:style/:filename'
        attachment.url.should == '/users/1/avatars/normal/me.png'
      end

      it "assumes an ':original' default style" do
        attachment.url = '/:class_name/:id/:attachment/:style/:filename'
        attachment.url.should == '/users/1/avatars/original/me.png'
      end
    end

    describe "#path" do
      it "builds its path from the url by default" do
        attachment.stub(:url => '/users/1/avatars/me.png')
        attachment.path.should == './public/users/1/avatars/me.png'
      end

      it "builds its path from a pattern if there's one" do
        attachment.path = './:class_name/:id/:attachment/:filename'
        attachment.path.should == './users/1/avatars/me.png'
      end

      it "accepts a style" do
        attachment.path = './:class_name/:id/:attachment/:style/:filename'
        attachment.path(:small).should == './users/1/avatars/small/me.png'
      end

      it "uses a default style if there isn't one" do
        attachment.default_style = :normal
        attachment.path = './:class_name/:id/:attachment/:style/:filename'
        attachment.path.should == './users/1/avatars/normal/me.png'
      end

      it "assumes an ':original' default style" do
        attachment.path = './:class_name/:id/:attachment/:style/:filename'
        attachment.path.should == './users/1/avatars/original/me.png'
      end
    end
  end
end
