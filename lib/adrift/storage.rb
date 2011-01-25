module Adrift
  module Storage
    class Filesystem
      attr_reader :stored, :removed

      def initialize
        @queue_for_storage = []
        @queue_for_removal = []
        @stored  = []
        @removed = []
      end

      def dirty?
        @queue_for_storage.any? || @queue_for_removal.any?
      end

      def store(source_path, destination_path)
        @queue_for_storage << [source_path, destination_path]
      end

      def store!
        @queue_for_storage.each do |source_path, destination_path|
          FileUtils.mkdir_p(File.dirname(destination_path))
          FileUtils.mv(source_path, destination_path)
          FileUtils.chmod(0644, destination_path)
        end
        @stored = @queue_for_storage.dup
        @queue_for_storage.clear
      end

      def remove(path)
        @queue_for_removal << path
      end

      def remove!
        @queue_for_removal.each do |path|
          FileUtils.rm(path) if File.exist?(path)
        end
        @removed = @queue_for_removal.dup
        @queue_for_removal.clear
      end

      def flush
        remove!
        store!
      end
    end
  end
end
