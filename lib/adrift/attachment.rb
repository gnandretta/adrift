module Adrift
  class Attachment
    attr_writer :default_url, :url, :path
    attr_reader :name, :model

    def initialize(name, model)
      @name, @model = name, model
      @default_url = '/images/missing.png'
      @url         = '/system/attachments/:class_name/:id/:attachment/:filename'
      @path        = './public:url'
    end

    def url
      specialize(empty? ? @default_url : @url)
    end

    def path
      specialize(@path) unless empty?
    end

    def empty?
      filename.nil?
    end

    def filename
      model.public_send("#{name}_filename")
    end

  private

    def specialize(str)
      Pattern.new(str).specialize(:attachment => self)
    end
  end
end
