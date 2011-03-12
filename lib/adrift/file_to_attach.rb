module Adrift
  class UnknownFileRepresentationError < StandardError
  end

  # Factory of the objects that Attachment#assign expects.  Theese are
  # adapters for the Rack and Rails' uploaded file representations and
  # File instances.
  module FileToAttach
    # Common adapter behaviour for the files who will be attached.
    module Adapter
      # Creates a new Adapter for the +file_representation+.
      def initialize(file_representation)
        @file_representation = file_representation
      end
    end

    # Namespace containing the adapters for the objects that
    # Attachment#assign expects.  They need to respond to
    # :original_filename and :path (what theese methods return it's
    # pretty much self-explanatory).
    module Adapters
      # Adapter that allows to attach an uploaded file within a Rack
      # (non-Rails) application.
      class Rack
        include Adapter

        # Indicates whether or not +file_representation+ is an
        # uploaded file within a Rack application.
        def self.recognize?(file_representation)
          file_representation.respond_to?(:has_key?) &&
            file_representation.has_key?(:filename) &&
            file_representation.has_key?(:tempfile)
        end

        # Uploaded file's original filename.
        def original_filename
          @file_representation[:filename]
        end

        # Uploaded file's path.
        def path
          @file_representation[:tempfile].path
        end
      end

      # Adapter that allows to attach an uploaded file within a Rails
      # application.
      class Rails
        include Adapter

        # Indicates whether or not +file_representation+ is an
        # uploaded file within a Rails application.
        def self.recognize?(file_representation)
          file_representation.respond_to?(:original_filename) &&
            file_representation.respond_to?(:tempfile)
        end

        # Uploaded file's original filename.
        def original_filename
          @file_representation.original_filename
        end

        # Uploaded file's path.
        def path
          @file_representation.tempfile.path
        end
      end

      # Adapter that allow to attach a local file.
      class LocalFile
        include Adapter

        # Indicates whether or not +file_representation+ is a local
        # file.
        def self.recognize?(file_representation)
          file_representation.respond_to?(:to_path)
        end

        # Local file's name.
        def original_filename
          ::File.basename(@file_representation.to_path)
        end

        # Local file's path.
        def path
          @file_representation.to_path
        end
      end
    end

    # Creates a new object that will that will act as an adapter for
    # +file_representation+, the object that represents the file to be
    # attached.  This adapter wil have the interface expected by
    # Attachment#assign.
    #
    # Raises Adrift::UnknownFileRepresentationError when it can't
    # recognize +file_representation+.
    def self.new(file_representation)
      adapter_class = find_adapter_class(file_representation)
      raise UnknownFileRepresentationError if adapter_class.nil?
      adapter_class.new(file_representation)
    end

  private

    # Finds the class of the object who will act as an adapter for
    # +file_representation+.
    def self.find_adapter_class(file_representation)
      adapter_classes.find do |adapter|
        adapter.respond_to?(:recognize?) &&
          adapter.recognize?(file_representation)
      end
    end

    # Lists the classes of the objects that act as adapters for the
    # file representations.
    def self.adapter_classes
      Adapters.constants.map { |class_name| Adapters.const_get(class_name) }
    end
  end
end
