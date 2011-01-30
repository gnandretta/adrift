require 'spec_helper'

module Adrift
  describe UpFile do
    context "within a rails application" do
      let(:up_file) { UpFile.new(up_file_representation) }
      let(:up_file_representation) do
        double('uploaded file', {
          :original_filename => 'me.png',
          :tempfile => double('tempfile', :path => '/tmp/123')
        })
      end

      describe "#original_filename" do
        it "returns the original filename of the uploaded file" do
          up_file.original_filename.should == up_file_representation.original_filename
        end
      end

      describe "#tempfile" do
        it "returns the uploaded tempfile" do
          up_file.tempfile.should == up_file_representation.tempfile
        end
      end

      describe "#path" do
        it "returns the uploaded tempfile's path" do
          up_file.path.should == up_file_representation.tempfile.path
        end
      end
    end

    context "within a rack (non rails) application" do
      let(:up_file) { UpFile.new(up_file_representation) }
      let(:up_file_representation) do
        {
          :filename => 'me.png',
          :tempfile => double('tempfile', :path => '/tmp/123')
        }
      end

      describe "#original_filename" do
        it "returns the original filename of the uploaded file" do
          up_file.original_filename.should == up_file_representation[:filename]
        end
      end

      describe "#tempfile" do
        it "returns the uploaded tempfile" do
          up_file.tempfile.should == up_file_representation[:tempfile]
        end
      end

      describe "#path" do
        it "returns the uploaded tempfile's path" do
          up_file.path.should == up_file_representation[:tempfile].path
        end
      end
    end
  end
end
