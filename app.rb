#!/usr/bin/env ruby -KU -rubygems
# stdlib
require 'logger'
require 'ostruct'
require 'yaml'

# rubygems
require 'descriptive-statistics'
require 'json'
require 'sinatra'
require 'sinatra/partial'
require 'sequel'
require 'maruku'

# config
ENV["TZ"] = "UTC"
config_files = ['config_local.yml', 'config_production.yml', 'config.yml']
config_file = config_files.detect {|ea| File.exist?(ea) }
CONFIG = YAML.load_file(config_file)

# When running tests, DB is already loaded as a temporary in-memory database
DB_URL = "mysql://#{CONFIG['db']['username']}:#{CONFIG['db']['password']}@#{CONFIG['db']['host']}/#{CONFIG['db']['name']}"
DB = Sequel.connect(DB_URL) unless defined?(DB)
DB.loggers << Logger.new($stdout) if ENV["ENABLE_SQL_LOGGING"] == "1"

module DeployMonitor; end

# application
require 'models'
require 'time_utils'
require 'views_helpers'
require 'web'
require 'api'
require 'paths'