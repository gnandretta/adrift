$:.unshift File.expand_path('../../../lib', __FILE__)
require 'cucumber'
require 'adrift'
require 'adrift/integration'

require 'active_record'
Adrift::Integration::ActiveRecord.install

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => '/tmp/adrift-activerecord.sqlite3'
)

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(:version => 1) do
  create_table 'ar_users', :force => true do |t|
    t.string 'name'
    t.string 'avatar_filename'
  end
end

class ARUser < ActiveRecord::Base
  validates :name, :presence => true
  attachment :avatar
end

require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
Adrift::Integration::DataMapper.install

DataMapper.setup(:default, 'sqlite::memory:')

class DMUser
  include DataMapper::Resource

  property :id,              Serial
  property :name,            String
  property :avatar_filename, String

  validates_presence_of :name

  attachment :avatar
end

DataMapper.finalize
DataMapper.auto_migrate!

Before do
  ARUser.delete_all
  DMUser.destroy
end

After  { system 'rm -rf public' }
