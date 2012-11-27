require 'rubygems'
require 'app'
require 'ruby-debug'
require 'benchmark'

sys = System[1]

limit = 100

Benchmark.benchmark do |x|
  x.report do
    progresses = Progress.join(
      Deploy.filter(:system_id => 1).order_by(:created_at.desc).limit(limit),
      :id => :deploy_id
    ).select(:progresses__id, :progresses__result, :progresses__step_id, :deploy_id)


    deploy_ids = progresses.map {|ea| ea.deploy_id }.uniq
    deploys = deploy_ids.map {|ea| Deploy[ea] }

    completed_deploys = deploys.select {|ea| ea.complete? }

    puts "completed_deploys.count: #{(completed_deploys.count).inspect}"
    puts "completed_deploys.size.to_f / deploys.size: #{(completed_deploys.size.to_f / deploys.size).inspect}"

    stats = StepStatistics.new(sys.steps, progresses.all)

    step_success_rates = sys.steps.map {|ea| [ea.id, stats.step_success_rate(ea.id)] }
    joint_probability = step_success_rates.inject(1.0) {|accum, ea| accum * ea[1] }

    puts "joint_probability: #{(joint_probability).inspect}"
  end
end