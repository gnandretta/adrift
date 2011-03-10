module Adrift
  module Adhesive
    module ClassMethods
      def has_attached_file(name, options={})
        include InstanceMethods

        attachment_definitions[name] = options.dup
        attachment_class = options.delete(:attachment_class) || Attachment
        define_callbacks

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

      def attachment_definitions
        @attachment_definitions ||= {}
      end
    end

    module InstanceMethods
      def attachments
        self.class.attachment_definitions.keys.map { |name| send(name) }
      end

      def send_to_attachments(message)
        attachments.each { |attachment| attachment.send(message) }
      end

      def save_attachments
        send_to_attachments(:save)
      end

      def destroy_attachments
        send_to_attachments(:destroy)
      end
    end
  end
end
