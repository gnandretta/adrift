module Adrift
  class Railtie < Rails::Railtie
    initializer "adrift.setup" do
      Pattern::Tags::Root.path = Rails.root
      ActiveSupport.on_load :active_record do
        require 'adrift/integration/active_record'
      end
      # TODO find out a better way to go (?)
      require 'adrift/integration/data_mapper'
    end
  end
end
