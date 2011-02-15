module Adrift
  module Processor
    class Thumbnail
      class Cli
        def run(source_path, destination_path, options={})
          options_str = options.map { |name, value| %(-#{name} "#{value}") }.join(' ')
          `convert #{source_path} #{options_str} #{destination_path}`
        end
      end

      attr_reader :processed_files

      def initialize(cli=Cli.new)
        @processed_files = {}
        @cli = cli
      end

      def process(source_path, styles={})
        @processed_files.clear
        styles.each do |name, definition|
          destination_path = File.join(File.dirname(source_path), "#{name}-#{File.basename(source_path)}")
          @cli.run(source_path, destination_path, options_for(definition))
          @processed_files[name] = destination_path
        end
      end

    private

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
