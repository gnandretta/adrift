module Adrift
  # Namespace containing the storage objects used by Attachment.
  #
  # They are used to save and remove files, and need to satisfy the
  # following interface:
  #
  # [<tt>#store(source_path, destination_path)</tt>]
  #   Adds a file to be stored.
  #
  # [<tt>#remove(path)</tt>]
  #   Indicates that a file will be removed.
  #
  # [<tt>#flush</tt>]
  #   Store and remove the previously specified files.
  #
  # [<tt>#stored</tt>]
  #   Array of stored files in the last flush.
  #
  # [<tt>#removed</tt>]
  #   Array of removed files in the last flush.
  module Storage
    # Stores and removes files to and from the filesystem using
    # queues.
    class Filesystem
      attr_reader :stored, :removed

      # Creates a new Filesystem object.
      def initialize
        @queue_for_storage = []
        @queue_for_removal = []
        @stored  = []
        @removed = []
      end

      # Indicates whether or not there are files that need to be
      # stored or removed.
      def dirty?
        @queue_for_storage.any? || @queue_for_removal.any?
      end

      # Adds the file +source_path+ to the storage queue, that will be
      # saved in +destination_path+.  Note that in order to actually
      # store the file you need to call #flush.
      def store(source_path, destination_path)
        @queue_for_storage << [source_path, destination_path]
      end

      # Stores the files placed in the storage queue.
      def store!
        @queue_for_storage.each do |source_path, destination_path|
          FileUtils.mkdir_p(File.dirname(destination_path))
          FileUtils.cp(source_path, destination_path)
          FileUtils.chmod(0644, destination_path)
        end
        @stored = @queue_for_storage.dup
        @queue_for_storage.clear
      end

      # Adds the file +path+ to the removal queue.  Note that in order
      # to actually remove the file you need to call #flush.
      def remove(path)
        @queue_for_removal << path
      end

      # Removes the files placed in the removal queue.
      def remove!
        @queue_for_removal.each do |path|
          FileUtils.rm(path) if File.exist?(path)
        end
        @removed = @queue_for_removal.dup
        @queue_for_removal.clear
      end

      # Removes and then stores the files placed in the removal and
      # storage queues, repectively.
      def flush
        remove!
        store!
      end
    end
  end
end
