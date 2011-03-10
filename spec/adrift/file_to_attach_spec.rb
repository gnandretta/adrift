require 'spec_helper'

module Adrift
  describe FileToAttach do
    context "when initialized with an unknown file representation" do
      it "raises an error" do
        expect {
          FileToAttach.new(Object.new)
        }.to raise_error(UnknownFileRepresentationError)
      end
    end

    context "within a rails application" do
      let(:file_to_attach) { FileToAttach.new(file_representation) }
      let(:file_representation) do
        double('uploaded file', {
          :original_filename => 'me.png',
          :tempfile => double('tempfile', :path => '/tmp/123')
        })
      end

      describe "#original_filename" do
        it "returns the original filename of the uploaded file" do
          file_to_attach.original_filename.should ==
            file_representation.original_filename
        end
      end

      describe "#path" do
        it "returns the uploaded tempfile's path" do
          file_to_attach.path.should == file_representation.tempfile.path
        end
      end
    end

    context "within a rack (non rails) application" do
      let(:file_to_attach) { FileToAttach.new(file_representation) }
      let(:file_representation) do
        {
          :filename => 'me.png',
          :tempfile => double('tempfile', :path => '/tmp/123')
        }
      end

      describe "#original_filename" do
        it "returns the original filename of the uploaded file" do
          file_to_attach.original_filename.should ==
            file_representation[:filename]
        end
      end

      describe "#path" do
        it "returns the uploaded tempfile's path" do
          file_to_attach.path.should == file_representation[:tempfile].path
        end
      end
    end

    context "when initialized with a local file" do
      let(:file_to_attach) { FileToAttach.new(file_representation) }
      let(:file_representation) do
        double('file', :to_path => '/avatars/me.png')
      end

      describe "#original_filename" do
        it "returns the local file name" do
          file_to_attach.original_filename.should == 'me.png'
        end
      end

      describe "#path" do
        it "returns the local file's path" do
          file_to_attach.path.should == file_representation.to_path
        end
      end
    end
  end
end
