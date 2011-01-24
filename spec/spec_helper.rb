require 'adrift'

module Adrift
  module Spec
    module Helpers
      def user_double(stubs={})
        default_stubs = { :id => 1, :avatar_filename => 'me.png' }
        user = double('user', default_stubs.merge(stubs))
        user.stub_chain(:class, :name).and_return('User')
        user
      end
    end
  end
end

RSpec.configure do |c|
  c.include Adrift::Spec::Helpers
end
