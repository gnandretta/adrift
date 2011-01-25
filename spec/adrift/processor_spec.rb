require 'spec_helper'

module Adrift
  module Processor
    describe Convert::Cli do
      describe "#run" do
        it "calls convert with the proper syntax" do
          cli = Convert::Cli.new
          cli.should_receive('`').with('convert /tmp/123 -resize "50x50^" -gravity "center" -extent "50x50" /tmp/small-123')
          cli.run('/tmp/123', '/tmp/small-123', :resize => '50x50^', :gravity => 'center', :extent => '50x50')
        end
      end
    end

    describe Convert do
      let(:cli) { double('cli').as_null_object }
      let(:processor) { Convert.new(cli) }

      describe "#processed_files" do
        context "for a newly instantiated processor" do
          it "returns an empty hash" do
            processor.processed_files.should == {}
          end
        end

        context "immediately after a proccess" do
          it "returns the generated files in the last process" do
            processor.process('/tmp/123', :small => '50x50', :normal => '100x100')
            processor.processed_files.should == { :small => '/tmp/small-123', :normal => '/tmp/normal-123' }
          end
        end

        context "after two proccess" do
          it "returns the generated files in the last process" do
            processor.process('/tmp/123', :small => '50x50')
            processor.process('/tmp/456', :normal => '100x100')
            processor.processed_files.should == {  :normal => '/tmp/normal-456' }
          end
        end
      end

      describe "#process" do
        it "doesn't do anything if no styles are given" do
          processor.process('/tmp/123', {})
          processor.processed_files.should be_empty
        end

        it "creates the thumbnails for the given styles" do
          cli.should_receive(:run).with('/tmp/123', '/tmp/small-123', :resize => '50x50!')
          cli.should_receive(:run).with('/tmp/123', '/tmp/normal-123', :resize => '100x100')
          processor.process('/tmp/123', :small => '50x50!', :normal => '100x100')
        end

        it "crops the image when the style definition ends with '#'" do
          cli.should_receive(:run).with('/tmp/123', '/tmp/small-123', :resize => '50x50^', :gravity => 'center', :background => 'None', :extent => '50x50')
          processor.process('/tmp/123', :small => '50x50#')
        end
      end
    end
  end
end
