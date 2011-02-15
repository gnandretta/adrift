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

    module Model
      attr_accessor :instance, :last_file, :last_attachment, :first_file,
                    :first_attachment

      def instantiate(orm, opts={ :valid => true })
        @last_id ||= 0
        self.instance = class_for(orm).new.tap do |user|
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

      def class_for(orm)
        case orm
        when :active_record then ARUser
        when :data_mapper   then DMUser
        end
      end
    end
  end
end

World(Adrift::Cucumber::Attachment)
World(Adrift::Cucumber::Model)
