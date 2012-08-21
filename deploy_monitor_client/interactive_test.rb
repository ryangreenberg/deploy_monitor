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

deploy = nil
begin
  deploy = dm.start_deploy(system_name)
  puts "Started new deploy id #{deploy.deploy_id}"
rescue RestClient::BadRequest => e
  puts "Error: #{e.response}"
  print "Resume active deploy? [y/n] "
  choice = STDIN.gets.strip.downcase
  if choice == 'y'
    deploy = dm.current_deploy(system_name)
    puts "Resumed deploy #{deploy.deploy_id}"
  else
    exit(1)
  end
end

puts "Steps to deploy #{system_name}:"
system.steps.each_with_index {|ea, i| puts "#{i + 1}. #{ea.name}" }

begin
  completed_steps = deploy.progress.map {|ea| ea["step_id"] }

  system.steps.each do |step|
    if completed_steps.include?(step.step_id)
      "Skipping #{step.name} (already done)"
      next
    end

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