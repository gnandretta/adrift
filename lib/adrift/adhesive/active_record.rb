module Adrift
  module Adhesive
    module ActiveRecord
      include ClassMethods

      def define_callbacks
        after_save     :save_attachments
        before_destroy :destroy_attachments
      end

      ::ActiveRecord::Base.send(:extend, self) if defined?(::ActiveRecord::Base)
    end
  end
end
