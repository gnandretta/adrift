module Adrift
  module Adhesive
    module DataMapper
      include ClassMethods

      def define_callbacks
        after  :save,    :save_attachments
        before :destroy, :destroy_attachments
      end

      ::DataMapper::Model.append_extensions(self) if defined?(::DataMapper::Model)
    end
  end
end
