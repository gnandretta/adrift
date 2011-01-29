require 'adrift'

module Adrift
  module Spec
    module Helpers
      def user_double_class
        @user_class ||= Class.new do
          attr_accessor :id, :avatar_filename

          def update_attributes(attrs)
            attrs.each { |name, value| send "#{name}=", value }
          end

          def self.name
            'User'
          end
        end
      end

      def user_double(attrs={})
        user_double_class.new.tap { |user| user.update_attributes(attrs) }
      end

      def up_file_double(stubs={})
        default_stubs = { :original_filename => 'new_me.png', :path => '/tmp/213' }
        double('up file', default_stubs.merge(stubs))
      end
    end
  end
end

class << FileUtils
  def chmod(*) end
  def cp(*) end
  def mkdir_p(*) end
  def rm(*) end
end

module Kernel
  def `(*) end
end

RSpec.configure do |c|
  c.include Adrift::Spec::Helpers
end
