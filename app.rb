#!/usr/bin/env ruby -KU -rubygems
# stdlib
require 'ostruct'
require 'yaml'

# rubygems
require 'json'
require 'sinatra'
require 'sequel'
require 'maruku'

# config
config_file = File.exist?('config_local.yml') ? 'config_local.yml' : 'config.yml'
CONFIG = YAML.load_file(config_file)
DB_URL = "mysql://#{CONFIG['db']['username']}:#{CONFIG['db']['password']}@#{CONFIG['db']['host']}/#{CONFIG['db']['name']}"
DB = Sequel.connect(DB_URL)

module DeployMonitor; end

# application
require 'models'
require 'time_utils'
require 'web'
require 'api'