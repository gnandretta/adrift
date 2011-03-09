module Adrift
  module Processor
    # Creates a set of thumbnails of an image.  To be fair, it just
    # tells ImageMagick to do it.
    class Thumbnail
      # A wrapper around ImageMagick's convert command line tool.
      class Cli
        # Runs +convert+ with the given +input+ and +options+, which
        # are expressed in a Hash.  The resulting image is stored in
        # +output+.
        def run(input, output, options={})
          options = options.map { |name, value| %(-#{name} "#{value}") }
          `convert #{input} #{options.join(' ')} #{output}`
        end
      end

      attr_reader :processed_files

      # Creates a new Thumbnail object.
      def initialize(cli=Cli.new)
        @processed_files = {}
        @cli = cli
      end

      # Creates a set of thumbnails for +image_path+ with the
      # dimensions specified in +styles+, which has the following
      # general form:
      #
      #     { style_name: 'definition', ... }
      #
      # where 'definition' is an
      # {ImageMagick's image geometry}[http://www.imagemagick.org/script/command-line-processing.php#geometry]
      # or has the form 'widthxheight#'.  For instance:
      #
      #     {
      #       fixed_width: '100',
      #       fixed_height: 'x100',
      #       max: '100x100',
      #       fixed: '100x100#'
      #     }
      #
      # will create, respectively, a thumbnail with a 100px width and
      # the corresponding height to preserve the ratio, a thumbnail
      # with a 100px height and the corresponding width to preserve
      # the ratio, a thumbnail with at most 100px width and at most
      # 100px height preserving the ratio, and a thumbnail with 100px
      # width and 100px height preserving the ratio (to do that, it
      # will resize the image trying to make it fit the specified
      # dimensions and then will crop its center).
      #
      # The thumbnail files are named after +image_path+ prefixed with
      # the style name and a hypen for every style.  The last created
      # thumbnails are accesible through #processed_files.
      def process(image_path, styles={})
        @processed_files.clear
        styles.each do |name, definition|
          thumbnail_path = File.join(
            File.dirname(image_path),
            "#{name}-#{File.basename(image_path)}"
          )
          @cli.run(image_path, thumbnail_path, options_for(definition))
          @processed_files[name] = thumbnail_path
        end
      end

    private

      # Returns a Hash with the options needed by convert to build a
      # thumbnail vgiven its +definition+.
      def options_for(definition)
        if definition.end_with?('#')
          {
            :resize => definition.tr('#', '^'),
            :gravity => 'center',
            :background => 'None',
            :extent => definition.tr('#', '')
          }
        else
          { :resize => definition }
        end
      end
    end
  end
end
