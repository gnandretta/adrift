require 'active_support/inflector'

module Adrift
  class Pattern
    def self.tags
      @tags ||= []
    end

    attr_reader :str

    def initialize(str)
      @str = str.dup
    end

    def specialize(*args)
      sorted_tags.inject(str) do |result, tag|
        result.gsub(tag.label) { tag.specialize(*args) }
      end
    end

    private

    def sorted_tags
      self.class.tags.sort_by(&:label).reverse
    end

    module Tags
      class Attachment
        def label
          ':attachment'
        end

        def specialize(options={})
          options[:attachment].name.to_s.underscore.pluralize
        end
      end
      Pattern.tags << Attachment.new

      class Style
        def label
          ':style'
        end

        def specialize(options={})
          options[:style].to_s
        end
      end
      Pattern.tags << Style.new

      class Url
        def label
          ':url'
        end

        def specialize(options={})
          options[:attachment].url.to_s
        end
      end
      Pattern.tags << Url.new

      class Class
        def label
          ':class'
        end

        def specialize(options={})
          options[:attachment].model.class.name.underscore.pluralize
        end
      end
      Pattern.tags << Class.new

      class ClassName
        def label
          ':class_name'
        end

        def specialize(options={})
          options[:attachment].model.class.name.demodulize.underscore.pluralize
        end
      end
      Pattern.tags << ClassName.new

      class Id
        def label
          ':id'
        end

        def specialize(options={})
          options[:attachment].model.id.to_s
        end
      end
      Pattern.tags << Id.new

      class Root
        def label
          ':root'
        end

        def specialize(options={})
          '.'
        end
      end
      Pattern.tags << Root.new

      class Filename
        def label
          ':filename'
        end

        def specialize(options={})
          options[:attachment].filename.to_s
        end
      end
      Pattern.tags << Filename.new

      class Basename
        def label
          ':basename'
        end

        def specialize(options={})
          filename = options[:attachment].filename.to_s
          filename.sub(File.extname(filename), '')
        end
      end
      Pattern.tags << Basename.new

      class Extension
        def label
          ':extension'
        end

        def specialize(options={})
          File.extname(options[:attachment].filename.to_s).sub('.', '')
        end
      end
      Pattern.tags << Extension.new

    end
  end
end
