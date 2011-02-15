$:.unshift File.expand_path('../../../lib', __FILE__)
require 'cucumber'
require 'adrift'

require 'active_record'
require 'adrift/active_record'

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
  has_attached_file :avatar
end

Before { ARUser.delete_all }
After  { system 'rm -rf public' }
