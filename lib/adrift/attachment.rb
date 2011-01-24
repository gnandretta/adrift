module Adrift
  class Attachment
    attr_reader :name, :model

    def initialize(name, model)
      @name, @model = name, model
    end

    def url
      '/images/missing.png'
    end

    def path
    end

    def empty?
      filename.nil?
    end

    def filename
      model.public_send("#{name}_filename")
    end
  end
end
