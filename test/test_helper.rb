require 'rubygems' unless defined?(Bundler)
require 'ruby-debug'
require 'sequel'
require 'rack/test'
require 'minitest/mock'
require 'minitest/autorun'
require 'rr'
require 'ostruct'

# Use in-memory database for tests
DB = Sequel.sqlite
Sequel.extension(:migration)
Sequel::Migrator.run(DB, 'db/migrations', :use_transactions=>false)

require 'app'

class MiniTest::Unit::TestCase
  # Use rr
  # See https://github.com/freerange/rr-with-minitest/blob/master/test.rb
  include RR::Adapters::MiniTest

  # Run tests within a transaction
  # See http://sequel.rubyforge.org/rdoc/files/doc/testing_rdoc.html
  alias_method :_original_run, :run

  def run(*args, &block)
    result = nil
    Sequel::Model.db.transaction(:rollback => :always) do
      result = _original_run(*args, &block)
    end
    result
  end
end

# Makes `TestStruct.new(:id => 5).id` work
class TestStruct < OpenStruct
  undef id
end