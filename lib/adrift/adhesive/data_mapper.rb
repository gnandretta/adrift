module Adrift
  module Adhesive
    module DataMapper
      include ClassMethods

      def define_callbacks
        after  :save,    :save_attachments
        before :destroy, :destroy_attachments
      end

      def self.install
        if defined?(::DataMapper::Model)
          ::DataMapper::Model.append_extensions(self)
        end
      end

      install

    end
  end
end
