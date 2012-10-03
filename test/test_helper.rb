require 'rubygems' unless defined?(Bundler)
require 'sequel'
require 'minitest/autorun'

# Use in-memory database for tests
DB = Sequel.sqlite
Sequel.extension(:migration)
Sequel::Migrator.run(DB, 'db/migrations', :use_transactions=>false)

# See http://sequel.rubyforge.org/rdoc/files/doc/testing_rdoc.html
class MiniTest::Unit::TestCase
  alias_method :_original_run, :run

  def run(*args, &block)
    result = nil
    Sequel::Model.db.transaction(:rollback => :always) do
      result = _original_run(*args, &block)
    end
    result
  end
end

require 'minitest/autorun'