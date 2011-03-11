require 'adrift/integration/base'

module Adrift
  module Integration
    module ActiveRecord
      include Base

      def attachment(*)
        super
        after_save     :save_attachments
        before_destroy :destroy_attachments
      end

      def self.install
        if defined?(::ActiveRecord::Base)
          ::ActiveRecord::Base.send(:extend, self)
        end
      end

      install

    end
  end
end
