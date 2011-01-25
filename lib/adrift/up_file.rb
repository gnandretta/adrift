module Adrift
  class UpFile
    module Proxies
      module Rack
        def original_filename
          @up_file_representation[:filename]
        end

        def tempfile
          @up_file_representation[:tempfile]
        end
      end

      module Rails
        def original_filename
          @up_file_representation.original_filename
        end

        def tempfile
          @up_file_representation.tempfile
        end
      end
    end

    def initialize(up_file_representation)
      if up_file_representation.respond_to?(:has_key?) && up_file_representation.has_key?(:filename) && up_file_representation.has_key?(:tempfile)
        extend Proxies::Rack
      elsif up_file_representation.respond_to?(:original_filename) && up_file_representation.respond_to?(:tempfile)
        extend Proxies::Rails
      else
        raise UnknownUpFileError
      end

      @up_file_representation = up_file_representation
    end

    def path
      tempfile.path
    end
  end
end
