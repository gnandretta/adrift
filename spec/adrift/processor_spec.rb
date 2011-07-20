require 'spec_helper'
require 'tmpdir'

module Adrift
  module Processor
    describe Thumbnail::Cli do
      describe "#run" do
        it "calls convert with the proper syntax" do
          cli = Thumbnail::Cli.new
          cli.should_receive('`').with('convert /path/to/123 -resize "50x50^" -gravity "center" -extent "50x50" /tmp/small-123')
          cli.run('/path/to/123', '/tmp/small-123', :resize => '50x50^', :gravity => 'center', :extent => '50x50')
        end
      end
    end

    describe Thumbnail do
      let(:cli) { double('cli').as_null_object }
      let(:processor) { Thumbnail.new(cli) }

      describe "#processed_files" do
        context "for a newly instantiated processor" do
          it "returns an empty hash" do
            processor.processed_files.should == {}
          end
        end

        context "immediately after a proccess" do
          it "returns the generated files in the last process" do
            processor.process('/path/to/123', :small => '50x50', :normal => '100x100')
            processor.processed_files.should == { :small => "#{Dir.tmpdir}/small-123", :normal => "#{Dir.tmpdir}/normal-123" }
          end
        end

        context "after two proccess" do
          it "returns the generated files in the last process" do
            processor.process('/path/to/123', :small => '50x50')
            processor.process('/path/to/456', :normal => '100x100')
            processor.processed_files.should == {  :normal => "#{Dir.tmpdir}/normal-456" }
          end
        end
      end

      describe "#process" do
        it "doesn't do anything if no styles are given" do
          processor.process('/path/to/123', {})
          processor.processed_files.should be_empty
        end

        it "creates the thumbnails for the given styles" do
          cli.should_receive(:run).with('/path/to/123', "#{Dir.tmpdir}/small-123", :resize => '50x50!')
          cli.should_receive(:run).with('/path/to/123', "#{Dir.tmpdir}/normal-123", :resize => '100x100')
          processor.process('/path/to/123', :small => '50x50!', :normal => '100x100')
        end

        it "crops the image when the style definition ends with '#'" do
          cli.should_receive(:run).with('/path/to/123', "#{Dir.tmpdir}/small-123", :resize => '50x50^', :gravity => 'center', :background => 'None', :extent => '50x50')
          processor.process('/path/to/123', :small => '50x50#')
        end
      end
    end
  end
end
