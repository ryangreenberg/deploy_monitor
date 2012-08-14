#!/usr/bin/env ruby -KU -rubygems

$:.unshift("./lib")
require 'deploy_monitor'

HOST = 'http://localhost:4567'

print "Enter system name: "
system_name = STDIN.gets.strip

dm = DeployMonitor::Client.new(HOST)
system = dm.get_system(system_name)

unless system
  puts "#{system_name} does not exist."
  exit
end

puts "Steps:"
system.steps.each_with_index {|ea, i| puts "#{i + 1}. #{ea.name}" }

begin
  deploy = dm.start_deploy(system_name)
rescue RestClient::BadRequest => e
  puts "Error: #{e.response}"
end

begin
  system.steps.each do |step|
    while true do
      print "[F]ail deploy or [c]ontinue to #{step.name}? [continue] "
      choice = STDIN.gets.strip.downcase
      if choice == 'f'
        deploy.fail
        exit
      else
        break
      end
    end

    deploy.progress_to(step.name)
  end
rescue Interrupt => e
  deploy.fail
end

print "Enter to complete deploy "
STDIN.gets
deploy.complete