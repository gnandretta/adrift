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

    def empty?
      filename.nil?
    end

    def filename
      model.public_send("#{name}_filename")
    end

  private

    def specialize(str, style)
      Pattern.new(str).specialize(:attachment => self, :style => style)
    end
  end
end
