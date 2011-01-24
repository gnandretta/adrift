require 'spec_helper'

module Adrift
  describe Attachment do
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

    describe "#empty?" do
      context "when a file hasn't been attached" do
        it "returns true" do
          attachment.should be_empty
        end
      end

      context "when a file has been attached" do
        it "returns false" do
          user.stub(:avatar_filename => 'me.png')
          attachment.should_not be_empty
        end

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
  end
end
