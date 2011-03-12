require 'active_support/inflector'

module Adrift
  # Provides a way for Attachment to generally define its paths and
  # urls, allowing to specialize them for every individual instance.
  #
  # In order to do this, a Pattern is build from a String comprised of
  # Tags (or more precisely, their labels) and when is asked to be
  # specialized for a given Attachment and style, it replaces these
  # Tags with they specialized values for that Attachment and that
  # style.
  class Pattern
    # Namespace containing the Tag objects used by Pattern.
    #
    # They are the building blocks of a Pattern.  A Pattern is
    # specialized by specializing the Tags that appear in its
    # string. They need to satisfy the following interface:
    #
    # [+#label+]
    #   Portion of Pattern#string that is replaced with the returned
    #   value of +#specialize+.
    #
    # [<tt>#specialize(options)</tt>]
    #   Value that will replace the label in the Pattern (+options+
    #   are the same passed to Pattern#specialize).
    module Tags
      # Pattern's tag that allows to generally express the
      # Attachment's name.
      class Attachment
        # Portion of Pattern#string that will be replaced.
        def label
          ':attachment'
        end

        # Pluralized Attachment's name.  Expects +options+ to include
        # the Attachment (+:attachment+ key).
        def specialize(options={})
          options[:attachment].name.to_s.underscore.pluralize
        end
      end

      # Pattern's tag that allows to generally express the selected
      # style.
      class Style
        # Portion of Pattern#string that will be replaced.
        def label
          ':style'
        end

        # Selected style, expects +options+ to include it (+:style+
        # key).
        def specialize(options={})
          options[:style].to_s
        end
      end

      # Pattern's tag that allows to generally express the
      # Attachment's url.
      class Url
        # Portion of Pattern#string that will be replaced.
        def label
          ':url'
        end

        # Attachment's url.  Expects +options+ to include the
        # Attachment (+:attachment+ key).
        def specialize(options={})
          options[:attachment].url.to_s
        end
      end

      # Pattern's tag that allows to generally express the model's to
      # which the Attachment belongs class name including its namespace.
      class Class
        # Portion of Pattern#string that will be replaced.
        def label
          ':class'
        end

        # Pluralized model's class name namespaced.  Expects +options+
        # to include the Attachment (+:attachment+ key).
        def specialize(options={})
          options[:attachment].model.class.name.underscore.pluralize
        end
      end

      # Pattern's tag that allows to generally express the model's to
      # which the Attachment belongs class name, without its
      # namespace.
      class ClassName
        # Portion of Pattern#string that will be replaced.
        def label
          ':class_name'
        end

        # Pluralized model's class name no namespaced.  Expects
        # +options+ to include the Attachment (+:attachment+ key).
        def specialize(options={})
          options[:attachment].model.class.name.demodulize.underscore.pluralize
        end
      end

      # Pattern's tag that allows to generally express the model's to
      # which the Attachment belongs ID.
      class Id
        # Portion of Pattern#string that will be replaced.
        def label
          ':id'
        end

        # Model's ID.  Expects +options+ to include the Attachment
        # (+:attachment+ key).
        def specialize(options={})
          options[:attachment].model.id.to_s
        end
      end

      # Pattern's tag that represents the application root directory.
      class Root
        class << self
          attr_accessor :path
        end

        # Portion of Pattern#string that will be replaced.
        def label
          ':root'
        end

        # Returns Adrift::Pattern::Tags::Root.path when defined, '.'
        # otherwise.
        def specialize(*)
          self.class.path || '.'
        end
      end

      # Pattern's tag that allows to generally express the
      # Attachment's file name.
      class Filename
        # Portion of Pattern#string that will be replaced.
        def label
          ':filename'
        end

        # Attachment's filename.  Expects +options+ to include the
        # Attachment (+:attachment+ key).
        def specialize(options={})
          options[:attachment].filename.to_s
        end
      end

      # Pattern's tag that allows to generally express the
      # Attachment's file base name.
      class Basename
        # Portion of Pattern#string that will be replaced.
        def label
          ':basename'
        end

        # Attachment's file base name.  Expects +options+ to include
        # the Attachment (+:attachment+ key).
        def specialize(options={})
          filename = options[:attachment].filename.to_s
          filename.sub(File.extname(filename), '')
        end
      end

      # Pattern's tag that allows to generally express the
      # Attachment's extension.
      class Extension
        # Portion of Pattern#string that will be replaced.
        def label
          ':extension'
        end

        # Attachment's file extension.  Expects +options+ to include
        # the Attachment (+:attachment+ key).
        def specialize(options={})
          File.extname(options[:attachment].filename.to_s).sub('.', '')
        end
      end
    end

    # Tags every instance of Pattern will be able to recognize (and
    # specialize).
    def self.tags
      @tags ||= []
    end

    attr_reader :string

    # Creates a new Pattern from a +string+ comprised of one o more
    # tag's labels.
    def initialize(string)
      @string = string.dup
    end

    # Returns #string with the known Tags replaced with their specific
    # values the given +options+.  While +options+ is just a Hash,
    # it's expected to include the Attachment this Pattern belongs to
    # (+:attachment+ key), and the selected style (+:style+ key).
    def specialize(options={})
      sorted_tags.inject(string) do |result, tag|
        result.gsub(tag.label) { tag.specialize(options) }
      end
    end

  private

    # Known Tags sorted in reverse label order.
    def sorted_tags
      self.class.tags.sort_by(&:label).reverse
    end
  end

  Pattern::Tags.constants.each do |class_name|
    Pattern.tags << Pattern::Tags.const_get(class_name).new
  end
end
