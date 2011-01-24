module Adrift
  class Attachment
    attr_reader :name, :model

    def initialize(name, model)
      @name, @model = name, model
    end

    def empty?
      model.public_send("#{name}_filename").nil?
    end
  end
end
