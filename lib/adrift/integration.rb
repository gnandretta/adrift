require 'adrift/integration/active_record'
require 'adrift/integration/data_mapper'

module Adrift
  # Namespace for the modules that ease the usage of Adrift in
  # conjuction with ORM libraries.
  #
  # This won't be loaded by default. In order to automatically try to
  # integrate Adrift with the ORM library in use (just ActiveRecord or
  # DataMapper for now), it is necessary to require this feature
  # manually:
  #
  #     require 'adrift/integration'
  #
  # It is also possible to request Adrift to integrate with a specific
  # library by requiring the corresponding integration feature:
  #
  #     require 'adrift/integration/active_record'
  #     require 'adrift/integration/data_mapper'
  #
  # In order to any of this to work, the ORM library must be loaded
  # before Adrift.  However, if (for whatever reason) that isn't the
  # case, besides requiring the integration for the library, it must
  # be installed by calling +install+ on the appropiate module.  For
  # instance, to integrate Adrift with ActiveRecord:
  #
  #     require 'adrift/integration/active_record'
  #     Adrift::Integration::ActiveRecord.install
  #
  # When the integration is ready, Base#attachment will become
  # available as a method of the model classes.  For instance, when
  # using ActiveRecord:
  #
  #     class User < ActiveRecord::Base
  #       attachment :avatar
  #     end
  module Integration
  end
end
