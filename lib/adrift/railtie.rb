module Adrift
  class Railtie < Rails::Railtie
    initializer "adrift.setup" do
      Pattern::Tags::Root.path = Rails.root
    end
  end
end
