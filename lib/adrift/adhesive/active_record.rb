module Adrift
  module Adhesive
    module ActiveRecord
      include ClassMethods

      def define_callbacks
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
