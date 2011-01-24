module Adrift
  class Attachment
    attr_reader :name, :model

    def initialize(name, model)
      @name, @model = name, model
    end
  end
end
