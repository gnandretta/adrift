require 'adrift/integration/base'

module Adrift
  module Integration
    module DataMapper
      include Base

      def attachment(*)
        super
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
