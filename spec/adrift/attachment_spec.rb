require 'spec_helper'

module Adrift
  describe Attachment do
    describe "#name" do
      it "returns the attachment's name" do
        attachment = Attachment.new(:avatar)
        attachment.name.should == :avatar
      end
    end
  end
end
