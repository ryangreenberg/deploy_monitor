#!/usr/bin/env rake
require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |t|
  t.libs = ["."]
  t.pattern = "test/**/*_test.rb"
end