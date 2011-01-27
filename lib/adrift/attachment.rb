module Adrift
  class Attachment
    attr_accessor :default_style, :styles, :storage, :processor
    attr_writer   :default_url, :url, :path
    attr_reader   :name, :model

    def initialize(name, model)
      @name, @model = name, model
      @default_style = :original
      @styles        = {}
      @default_url   = '/images/missing.png'
      @url           = '/system/attachments/:class_name/:id/:attachment/:filename'
      @path          = './public:url'
      @storage       = Storage::Filesystem.new
      @processor     = Processor::Convert.new
    end

    def dirty?
      !@up_file.nil?
    end

    def url(style=default_style)
      specialize(empty? ? @default_url : @url, style)
    end

    def path(style=default_style)
      specialize(@path, style) unless empty?
    end

    def assign(up_file)
      enqueue_files_for_removal unless empty? || dirty?
      model_send(:filename=, up_file.original_filename.to_s.tr('^a-zA-Z0-9.', '_'))
      @up_file = up_file
    end

    def save
      return unless dirty?
      enqueue_files_for_storage
      storage.flush
      @up_file = nil
    end

    def destroy
      return if empty?
      enqueue_files_for_removal unless dirty?
      storage.flush
      model_send(:filename=, nil)
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
      Pattern.new(str).specialize(:attachment => self, :style => style)
    end

    def enqueue_files_for_removal
      [:original, *styles.keys].uniq.each { |style| storage.remove path(style) }
    end

    def enqueue_files_for_storage
      files_for_storage.each { |style, file| storage.store(file, path(style)) }
    end

    def files_for_storage
      processor.process(@up_file.path, styles)
      processor.processed_files.dup.tap do |files|
        files[:original] ||= @up_file.path
      end
    end
  end
end
