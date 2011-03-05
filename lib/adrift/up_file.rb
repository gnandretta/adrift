module Adrift
  class UnknownUpFileRepresentationError < StandardError
  end

  module UpFile
    module Adapter
      def initialize(up_file_representation)
        @up_file_representation = up_file_representation
      end

      def path
        tempfile.path
      end
    end

    module Adapters
      class Rack
        include Adapter

        def self.recognize?(up_file_representation)
          up_file_representation.respond_to?(:has_key?) &&
            up_file_representation.has_key?(:filename) &&
            up_file_representation.has_key?(:tempfile)
        end

        def original_filename
          @up_file_representation[:filename]
        end

        def tempfile
          @up_file_representation[:tempfile]
        end
      end

      class Rails
        include Adapter

        def self.recognize?(up_file_representation)
          up_file_representation.respond_to?(:original_filename) &&
            up_file_representation.respond_to?(:tempfile)
        end

        def original_filename
          @up_file_representation.original_filename
        end

        def tempfile
          @up_file_representation.tempfile
        end
      end

      class File
        include Adapter

        def self.recognize?(up_file_representation)
          up_file_representation.respond_to?(:to_path)
        end

        def original_filename
          ::File.basename(@up_file_representation)
        end

        def tempfile
          @up_file_representation
        end
      end
    end

    def self.new(up_file_representation)
      adapter_class = find_adapter_class(up_file_representation)
      raise UnknownUpFileRepresentationError if adapter_class.nil?
      adapter_class.new(up_file_representation)
    end

  private

    def self.find_adapter_class(up_file_representation)
      adapter_classes.find do |adapter|
        adapter.respond_to?(:recognize?) &&
          adapter.recognize?(up_file_representation)
      end
    end

    def self.adapter_classes
      Adapters.constants.map { |class_name| Adapters.const_get(class_name) }
    end
  end
end
