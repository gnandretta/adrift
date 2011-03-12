require 'adrift/integration/base'

module Adrift
  module Integration
    # Integrates Adrift with ActiveRecord.
    module ActiveRecord
      include Base

      # Does everything Base#attachment does, but it also registers
      # the callbacks to save the attachments when the model is saved,
      # and to destroy them, when it is destroyed.
      def attachment(*)
        super
        after_save     :save_attachments
        before_destroy :destroy_attachments
      end

      # Integrates Adrift with ActiveRecord if it has been loaded.
      def self.install
        if defined?(::ActiveRecord::Base)
          ::ActiveRecord::Base.send(:extend, self)
        end
      end

      install

    end
  end
end
