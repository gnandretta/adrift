module Adrift
  class UpFile
    module Proxy
      def initialize(up_file_representation)
        @up_file_representation = up_file_representation
      end

      def path
        tempfile.path
      end
    end

    module Proxies
      class Rack
        include Proxy

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
        include Proxy

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
        include Proxy

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
      proxy = proxy_for(up_file_representation)
      raise UnknownUpFileError if proxy.nil?
      proxy.new(up_file_representation)
    end

    private

    def self.proxy_for(up_file_representation)
      proxies.find do |proxy|
        proxy.respond_to?(:recognize?) &&
          proxy.recognize?(up_file_representation)
      end
    end

    def self.proxies
      Proxies.constants.map { |proxy_name| Proxies.const_get(proxy_name) }
    end
  end
end
