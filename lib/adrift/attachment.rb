module Adrift
  class Attachment
    attr_accessor :default_style, :styles, :storage, :processor, :pattern_class
    attr_writer   :default_url, :url, :path
    attr_reader   :name, :model

    def self.config(&block)
      config = BasicObject.new
      def config.method_missing(m, *args)
        options = Attachment.default_options
        options[m] = args.first if options.has_key?(m)
      end
      config.instance_eval(&block)
    end

    def self.default_options
      @default_options ||= {
        :default_style => :original,
        :styles        => {},
        :default_url   => '/images/missing.png',
        :url           => '/system/attachments/:class_name/:id/:attachment/:filename',
        :path          => ':root/public:url',
        :storage       => Proc.new { Storage::Filesystem.new },
        :processor     => Proc.new { Processor::Thumbnail.new },
        :pattern_class => Pattern
      }
    end

    def self.reset_default_options
      @default_options = nil
    end

    def initialize(name, model, options={})
      self.class.default_options.merge(options).each do |name, value|
        writer_name = "#{name}="
        if respond_to?(writer_name)
          send writer_name, value.is_a?(Proc) ? value.call : value
        end
      end
      @name, @model = name, model
    end

    def dirty?
      !@up_file.nil? || storage.dirty?
    end

    def url(style=default_style)
      specialize(empty? ? @default_url : @url, style)
    end

    def path(style=default_style)
      specialize(@path, style) unless empty?
    end

    def assign(up_file)
      enqueue_files_for_removal
      model_send(:filename=, up_file.original_filename.to_s.tr('^a-zA-Z0-9.', '_'))
      @up_file = up_file
    end

    def clear
      enqueue_files_for_removal
      @up_file = nil
      model_send(:filename=, nil)
    end

    def save
      unless @up_file.nil?
        processor.process(@up_file.path, styles)
        enqueue_files_for_storage
      end
      storage.flush
      @up_file = nil
    end

    def destroy
      clear
      save
    end

    def empty?
      filename.nil?
    end

    def filename
      model_send(:filename)
    end

  private

    def model_send(message_without_prefix, *args)
      model.public_send("#{name}_#{message_without_prefix}", *args)
    end

    def specialize(str, style)
      pattern_class.new(str).specialize(:attachment => self, :style => style)
    end

    def enqueue_files_for_removal
      return if empty? || dirty?
      [:original, *styles.keys].uniq.each { |style| storage.remove path(style) }
    end

    def enqueue_files_for_storage
      files_for_storage.each { |style, file| storage.store(file, path(style)) }
    end

    def files_for_storage
      processor.processed_files.dup.tap do |files|
        files[:original] ||= @up_file.path
      end
    end
  end
end
