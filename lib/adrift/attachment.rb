module Adrift
  class Attachment
    attr_accessor :default_style
    attr_writer   :default_url, :url, :path
    attr_reader   :name, :model

    def initialize(name, model)
      @name, @model = name, model
      @default_style = :original
      @default_url   = '/images/missing.png'
      @url           = '/system/attachments/:class_name/:id/:attachment/:filename'
      @path          = './public:url'
    end

    def url(style=default_style)
      specialize(empty? ? @default_url : @url, style)
    end

    def path(style=default_style)
      specialize(@path, style) unless empty?
    end

    def assign(up_file)
      model_send(:filename=, up_file.original_filename.to_s.tr('^a-zA-Z0-9.', '_'))
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
  end
end
