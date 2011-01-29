require 'spec_helper'

module Adrift::Storage
  describe Filesystem do
    let(:storage) { Filesystem.new }

    describe "#dirty?" do
      context "for a newly instantiated storage" do
        it "returns false" do
          storage.should_not be_dirty
        end
      end

      context "when it hasn't been flushed" do
        context "and there's a file that needs to be stored" do
          it "reutrns false" do
            storage.store('/tmp/1', '/path/to/storage/1/file')
            storage.should be_dirty
          end
        end

        context "and there's a file that needs to be removed" do
          it "returns false" do
            storage.remove('/path/to/storage/1/file')
            storage.should be_dirty
          end
        end
      end

      context "immediately after a flush" do
        it "returns true" do
          storage.store('/tmp/1', '/path/to/storage/1/file')
          storage.remove('/path/to/storage/2/file')
          storage.flush
          storage.should_not be_dirty
        end
      end
    end

    describe "#removed" do
      context "for a newly instantiated storage" do
        it "returns an empty array" do
          storage.removed.should == []
        end
      end

      context "immediately after a flush" do
        before do
          storage.remove('/path/to/storage/1/file')
          storage.remove('/path/to/storage/2/file')
          storage.flush
        end

        it "returns the files removed in the last flush" do
          storage.removed.should include('/path/to/storage/1/file')
          storage.removed.should include('/path/to/storage/2/file')
          storage.removed.size.should == 2
        end

        context "when a file has been enqueued for removal" do
          before { storage.remove('/path/to/storage/3/file') }

          it "doesn't include it before a flush" do
            storage.removed.should_not include('/path/to/storage/3/file')
          end

          it "only contains it after a flush" do
            storage.flush
            storage.removed.should == ['/path/to/storage/3/file']
          end
        end
      end
    end

    describe "#stored" do
      context "for a newly instantiated storage" do
        it "returns an empty array" do
          storage.stored.should == []
        end
      end

      context "immediately after a flush" do
        before do
          storage.store('/tmp/1', '/path/to/storage/1/file')
          storage.store('/tmp/2', '/path/to/storage/2/file')
          storage.flush
        end

        it "returns the files stored in the last flush" do
          storage.stored.should include(['/tmp/1', '/path/to/storage/1/file'])
          storage.stored.should include(['/tmp/2', '/path/to/storage/2/file'])
          storage.stored.size.should == 2
        end

        context "when a file has been enqueued for storage" do
          before { storage.store('/tmp/3', '/path/to/storage/3/file') }

          it "doesn't include it before a flush" do
            storage.stored.should_not include(['/tmp/3', '/path/to/storage/3/file'])
          end

          it "only contains it after a flush" do
            storage.flush
            storage.stored.should == [['/tmp/3', '/path/to/storage/3/file']]
          end
        end
      end
    end

    describe "#remove!" do
      before { File.stub(:exist? => true) }

      context "when there're files that need to be removed" do
        before do
          storage.remove('/path/to/storage/1/file')
          storage.remove('/path/to/storage/2/file')
        end

        it "removes the specified files" do
          FileUtils.should_receive(:rm).with('/path/to/storage/1/file')
          FileUtils.should_receive(:rm).with('/path/to/storage/2/file')
          storage.remove!
        end

        it "doesn't try to remove inexistent files" do
          File.stub(:exist?) { |path| path != '/path/to/storage/1/file' }
          FileUtils.should_not_receive(:rm).with('/path/to/storage/1/file')
          FileUtils.should_receive(:rm).with('/path/to/storage/2/file')
          storage.remove!
        end
      end
    end

    describe "#store!" do
      before { File.stub(:exist? => true) }

      context "when there're files that need to be stored" do
        before do
          storage.store('/tmp/1', '/path/to/storage/1/file')
          storage.store('/tmp/2', '/path/to/storage/2/file')
        end

        it "tries to create the directories for the files to store" do
          FileUtils.should_receive(:mkdir_p).with('/path/to/storage/1')
          FileUtils.should_receive(:mkdir_p).with('/path/to/storage/2')
          storage.store!
        end

        it "moves the specified files to their destination path" do
          FileUtils.should_receive(:cp).with('/tmp/1', '/path/to/storage/1/file')
          FileUtils.should_receive(:cp).with('/tmp/2', '/path/to/storage/2/file')
          storage.store!
        end

        it "changes the permissions of the stored files" do
          FileUtils.should_receive(:chmod).with(0644, '/path/to/storage/1/file')
          FileUtils.should_receive(:chmod).with(0644, '/path/to/storage/2/file')
          storage.store!
        end
      end

      describe "for each file" do
        it "creates its directory, then moves it there and then sets its permissions" do
          storage.store('/tmp/1', '/path/to/storage/1/file')
          FileUtils.should_receive(:mkdir_p).ordered
          FileUtils.should_receive(:cp).ordered
          FileUtils.should_receive(:chmod).ordered
          storage.store!
        end
      end
    end

    describe "#flush" do
      it "removes the enqueued files for removal and then stores the enqueued for storage" do
        storage.should_receive(:remove!).ordered
        storage.should_receive(:store!).ordered
        storage.flush
      end
    end
  end
end
