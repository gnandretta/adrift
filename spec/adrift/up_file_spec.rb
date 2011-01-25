require 'spec_helper'

module Adrift
  describe UpFile do
    shared_examples_for "any up file" do
      let(:tempfile) { double('tempfile', :path => '/tmp/123') }
      let(:original_filename) { 'me.png' }
      let(:up_file) { UpFile.new(up_file_representation) }

      describe "#original_filename" do
        it "returns the original filename of the uploaded file" do
          up_file.original_filename.should == 'me.png'
        end
      end

      describe "#tempfile" do
        it "returns the uploaded tempfile" do
          up_file.tempfile.should == tempfile
        end
      end

      describe "#path" do
        it "returns the uploaded tempfile's path" do
          up_file.path.should == '/tmp/123'
        end
      end
    end

    describe "within a rails application" do
      let(:up_file_representation) do
        double('uploaded file', :original_filename => original_filename, :tempfile => tempfile)
      end

      it_behaves_like "any up file"
    end

    describe "within a rack (non rails) application" do
      let(:up_file_representation) do
        { :filename => original_filename, :tempfile => tempfile }
      end

      it_behaves_like "any up file"
    end
  end
end
