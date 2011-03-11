require 'adrift/integration/base'

module Adrift
  module Integration
    # Integrates Adrift with DataMapper.
    module DataMapper
      include Base

      # Does everything Base#Attachment does, but it also registers
      # the callbacks to save the attachments when the model is saved,
      # and to destroy them, when it is destroyed.
      def attachment(*)
        super
        after  :save,    :save_attachments
        before :destroy, :destroy_attachments
      end

      # Integrates Adrift with DataMapper if it has been loaded.
      def self.install
        if defined?(::DataMapper::Model)
          ::DataMapper::Model.append_extensions(self) 
        end
      end

      install

    end
  end
end
