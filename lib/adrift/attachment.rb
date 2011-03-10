module Adrift
  # Handles attaching files to a model, allowing to automatically
  # create different stlyes (versions) of them.
  #
  # Actually, this class's responsibility consist in just directing
  # this process: it relies on a #storage object, for saving and
  # removing the attached files, and on a #processor object, for the
  # task of generating the different versions of a file from the given
  # style definition.
  #
  # Also, it provides a naive pattern mechanism to express the
  # attachment's #path and #url.
  class Attachment
    attr_accessor :default_style, :styles, :storage, :processor, :pattern_class
    attr_writer   :default_url, :url, :path
    attr_reader   :name, :model

    # Allows to change the options used for every new attachment.  For
    # instance, to change the :default_style and :path options:
    #
    #   Adrift::Attachment.config do
    #     default_style :default
    #     path '/custom/storage/path/:url'
    #   end
    #
    # See ::default_options for a list of the supported options.
    def self.config(&block)
      config = BasicObject.new
      def config.method_missing(m, *args)
        options = Attachment.default_options
        options[m] = args.first if options.has_key?(m)
      end
      config.instance_eval(&block)
    end

    # Default options for every new attachment.  These are:
    # * :default_style: Style assumed by #url and #path when no one
    #   has been provided.
    # * :styles: Hash with the style definitions, they keys are the
    #   style names, and the values whatever makes sense to the
    #   processor to generate the alternate versions of the attached
    #   file.
    # * :default_url: String pattern used to build the returned value
    #   of #url when the attachment is empty.
    # * :url: String pattern used to build the returned value of #url
    #   when the attachment is not empty.
    # * :path: String pattern used to build the path where the
    #   attachment will be stored (and will be returned by #path).
    #   NOTE: please beware that if you have an attachment with more
    #   than one style, the path must be unique for each one,
    #   otherwise the stored files will be overwritten.  In the most
    #   common case, what this means is that the path option must have
    #   a +:style+ tag.
    # * :storage: Object delegated with the task of saving and
    #   removing files.
    # * :processor: Object delegated with the task of generating the
    #   alternate versions of the attached file from the :styles.
    # * :pattern_class: The class used to build the urls and paths of
    #   the attachment from the string patterns provided.
    #
    # See the source of this method to know the values of this
    # options. Note that these values can be changed for every new
    # attachment with ::config, or in a per-attachment basis, when
    # they are constructed with ::new, or after, just calling the
    # attachment's writer method named after the option.
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

    # Restores the attachment's options to their default values.  See
    # the source of ::default_options to know what these default
    # values are.
    def self.reset_default_options
      @default_options = nil
    end

    # Creates a new Attachment object. +name+ is the name of the
    # attachment, +model+ is the model object it's attached to, and
    # +options+ is a hash that lets customize the attachment's
    # behaviour.
    #
    # The +model+ object must allow reading and writing to an
    # attribute called after the attachment's +name+.  For instance,
    # for an attachment named +avatar+, the +model+ need to respond to
    # the methods +avatar_filename+ and +avatar_filename=+.
    #
    # See ::default_options for a list of the supported +options+.
    # The options passed here will overwrite the default ones.
    def initialize(name, model, options={})
      self.class.default_options.merge(options).each do |name, value|
        writer_name = "#{name}="
        if respond_to?(writer_name)
          send writer_name, value.is_a?(Proc) ? value.call : value
        end
      end
      @name, @model = name, model
    end

    # Indicates whether or not there are changes that need to be
    # saved, that is, files that need to be processed and stored
    # and/or removed.
    def dirty?
      !@file_to_attach.nil? || storage.dirty?
    end

    # Returns the attachment's url for the given +style+.  If no
    # +style+ is given it assumes the :default_style option.  Also, it
    # uses the :url or the :default_url option, depending whether or
    # not the attachment is empty.
    def url(style=default_style)
      specialize(empty? ? @default_url : @url, style)
    end

    # Returns the attachment's path for the given +style+.  If no
    # +style+ is given it assumes :default_style option.  When the
    # attachment is empty it returns +nil+.
    def path(style=default_style)
      specialize(@path, style) unless empty?
    end

    # Makes +file_to_attach+ the new attached file, but it won't be
    # stored nor processed until the attachment receives #save.  It
    # also updates the model's attachment filename attribute.
    #
    # See FileToAttach::Adapters for the expected interface of
    # +file_to_attach+.
    def assign(file_to_attach)
      enqueue_files_for_removal
      model_send(
        :filename=,
        file_to_attach.original_filename.to_s.tr('^a-zA-Z0-9.', '_')
      )
      @file_to_attach = file_to_attach
    end

    # Throws away the current attached file, but it won't actually be
    # removed until the attachment receives #save.  It also sets the
    # model's attachment filename attribute to nil.
    def clear
      enqueue_files_for_removal
      @file_to_attach = nil
      model_send(:filename=, nil)
    end

    # When there is a new attached file will store and process it, and
    # if there was a previous attached file it will also remove it.
    # On the other hand it will remove the current attached file if it
    # was thrown away (in other words, the attachment has received
    # #clear).
    #
    # Generally, this will get called when the model is saved.
    def save
      unless @file_to_attach.nil?
        processor.process(@file_to_attach.path, styles)
        enqueue_files_for_storage
      end
      storage.flush
      @file_to_attach = nil
    end

    # Removes the current attached file, setting the model's
    # attachment filename attribute to nil.
    def destroy
      clear
      save
    end

    # Indicates whether or not there is a file attached.
    def empty?
      filename.nil?
    end

    # Returns the attachment's file name.
    def filename
      model_send(:filename)
    end

  private

    # Sends the message +message_without_prefix+ to the model,
    # prefixed with the attachment's name, and passing the given
    # +args+.
    def model_send(message_without_prefix, *args)
      model.public_send("#{name}_#{message_without_prefix}", *args)
    end

    # Specializes the string pattern +str+, for the attachment which
    # receives this message and the given +style+.
    def specialize(str, style)
      pattern_class.new(str).specialize(:attachment => self, :style => style)
    end

    # Adds all the current attached files to the storage's removal
    # queue, unless they don't exist or are already there.
    def enqueue_files_for_removal
      return if empty? || dirty?
      [:original, *styles.keys].uniq.each { |style| storage.remove path(style) }
    end

    # Adds all the current attached files to the storage's queue.
    def enqueue_files_for_storage
      files_for_storage.each { |style, file| storage.store(file, path(style)) }
    end

    # Returns a hash containing the files that need to be stored as
    # values and their styles as keys.
    def files_for_storage
      processor.processed_files.dup.tap do |files|
        files[:original] ||= @file_to_attach.path
      end
    end
  end
end
