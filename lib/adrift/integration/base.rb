module Adrift
  module Integration
    # Common integration code.
    module Base
      # Methods that handle the communication with the Attachments of
      # a given model.
      #
      # They are included in the model class by Base#attachment.
      module InstanceMethods
        # Attachment objects that belongs to the model.  It needs the
        # model class to be able to respond to
        # +attachment_definitions+ with a Hash where the keys are the
        # Attachment names.
        def attachments
          self.class.attachment_definitions.keys.map { |name| send(name) }
        end

        # Sends +message+ to the Attachment objects that belongs to
        # the model.
        def send_to_attachments(message)
          attachments.each { |attachment| attachment.send(message) }
        end

        # Sends the message :save to the Attachment objects that
        # belongs to the model.
        def save_attachments
          send_to_attachments(:save)
        end

        # Sends the message :destroy to the Attachment objects that
        # belongs to the model.
        def destroy_attachments
          send_to_attachments(:destroy)
        end
      end

      # Defines accessor methods for the Attachment, includes
      # InstanceMethods in the model class, and stores the attachment
      # +name+ and +options+ (see #attachment_definitions) for future
      # reference.
      #
      # +name+ and +options+ are the arguments that Attachment::new
      # expects, and receives, with the exception that it accepts an
      # <tt>:attachment_class</tt> option with a custom class to use
      # instead of Attachment.  In that case,
      # <tt>options[:attachment_class]</tt> will receive +new+ with
      # +name+, the model, and +options+ without :attachment_class.
      #
      # The accessor methods are named after the Attachment: the
      # following code will define +avatar+ and <tt>avatar=</tt> on
      # the model class that receives #attachment:
      #
      #     attachment :avatar
      #
      # The writter method (in the example: <tt>avatar=</tt>) will
      # assign to the attachment the results of calling
      # FileToAttach::new with its argument.  See Attachment#assign
      # for more details.
      def attachment(name, options={})
        include InstanceMethods

        attachment_definitions[name] = options.dup
        attachment_class = options.delete(:attachment_class) || Attachment

        define_method(name) do
          instance_variable = "@#{name}_attachment"
          unless instance_variable_defined?(instance_variable)
            attachment = attachment_class.new(name, self, options)
            instance_variable_set(instance_variable, attachment)
          end
          instance_variable_get(instance_variable)
        end

        define_method("#{name}=") do |file_representation|
          send(name).assign(Adrift::FileToAttach.new(file_representation))
        end
      end

      # Attachment definitions for the model.  Is a Hash where the
      # keys are the +names+ and the values are the +options+ passed
      # to #attachment.
      def attachment_definitions
        @attachment_definitions ||= {}
      end
    end
  end
end
