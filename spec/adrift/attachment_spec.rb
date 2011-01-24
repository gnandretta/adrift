require 'spec_helper'

module Adrift
  shared_examples_for "any attachment" do
    describe "#empty?" do
      context "when a file has been assigned" do
        it "returns true" do
          pending do
            attachment.assign(double('up file'))
            attachment.should_not be_empty
          end
        end
      end
    end
  end

  describe Attachment, "instantiation" do
    let(:user) { double('user', :avatar_filename => nil) }
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
    let(:user) { double('user', :avatar_filename => nil) }
    let(:attachment) { Attachment.new(:avatar, user) }

    it_behaves_like "any attachment"

    describe "#empty?" do
      it "returns true" do
        attachment.should be_empty
      end
    end
  end

  describe Attachment, "when isn't empty" do
    let(:user) { double('user', :avatar_filename => 'me.png') }
    let(:attachment) { Attachment.new(:avatar, user) }

    it_behaves_like "any attachment"

    describe "#empty?" do
      it "returns false" do
        attachment.should_not be_empty
      end
    end
  end
end
