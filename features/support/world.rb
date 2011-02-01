require 'active_record'
require 'adrift/active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => '/tmp/adrift-activerecord.sqlite3'
)

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(:version => 1) do
  create_table 'users', :force => true do |t|
    t.string 'name'
    t.string 'avatar_filename'
  end
end

class User < ActiveRecord::Base
  validates :name, :presence => true
  has_attached_file :avatar
end

module Adrift
  module Cucumber
    module Attachment
      def read_file(path)
        File.open(path, 'rb') { |io| io.read }
      end

      def original_file
        'spec/fixtures/me.png'
      end

      def other_original_file
        'spec/fixtures/me_no_colors.png'
      end
    end

    module ActiveRecord
      attr_accessor :instance, :last_file, :last_attachment, :first_file,
                    :first_attachment

      def instantiate(opts={ :valid => true })
        @last_id ||= 0
        self.instance = User.new.tap do |user|
          user.id   = @last_id += 1
          user.name = 'ohhgabriel' if opts[:valid]
        end
      end

      def attached?
        !last_file.nil?
      end

      def attach(path)
        instance.avatar = File.new(path)
        if first_file.nil?
          self.first_file = last_file
          self.first_attachment = last_attachment
        end
        self.last_file = path
        self.last_attachment = instance.avatar.path
      end

      def detach
        instance.avatar.destroy
      end
    end
  end
end

World(Adrift::Cucumber::Attachment)
World(Adrift::Cucumber::ActiveRecord)

Before { User.delete_all }
After  { system 'rm -rf public' }
