require 'optparse'
require 'highline/import'

module DeployMonitor
  class CLI
    def initialize
      @options = {}
    end

    def default_options
      {}
    end

    def option_parser
      OptionParser.new do |opts|
        opts.on("-h", "--host <host>", "URL to Deploy Monitor installation") do |h|
          @options[:host] = h
        end
      end
    end

    def parse(args)
      begin
        option_parser.parse(args)
      rescue OptionParser::InvalidOption => e
        error_and_exit("unknown argument '#{e.args}'\nTry --help for help")
      rescue OptionParser::MissingArgument => e
        error_and_exit("missing argument for '#{e.args}'\nTry --help for help")
      end

      @options = default_options.merge(@options)
    end

    def start_interactive_session
      @client = DeployMonitor::Client.new(@options[:host])
      @system = prompt_for_system
      prompt_for_system_action
    end

    def prompt_for_system
      all_systems = @client.all_systems
      system_names = all_systems.map {|sys| sys.name }
      selected_system_name = choose(*system_names) do |menu|
        menu.header = "Select a system"
        menu.prompt = "> "
      end
      all_systems.detect {|sys| sys.name == selected_system_name}
    end

    def prompt_for_system_action
      while true
        system_actions = [:start_deploy, :show_steps]
        action = choose(*system_actions) do |menu|
          menu.header = "Select an action for #{@system.name}"
          menu.prompt = "> "
        end
        send("prompt_for_#{action}")
      end
    end

    def prompt_for_start_deploy
      begin
        @deploy = @system.start_deploy
        say("Started new deploy id #{@deploy.deploy_id}")
      rescue DeployMonitor::Error::DeployInProgress => e
        say("Deploy already in progress for #{@system.name}")
        resume_deploy = agree("Resume active deploy? ")
        return unless resume_deploy
        @deploy = @system.current_deploy
        say("Resumed deploy #{@deploy.deploy_id}")
      end
      if @deploy.predicted_finished_at
        expected_duration_mins = ((@deploy.predicted_finished_at - Time.now) / 60).round
        pretty_time = @deploy.predicted_finished_at.strftime('%H:%M')
        say("Deploy should be complete in #{expected_duration_mins} minutes at #{pretty_time}")
      end
      if @deploy.completion_probability
        say("(#{(@deploy.completion_probability * 100).round}% chance of success)")
      end

      prompt_for_deploy_steps
    end

    def prompt_for_show_steps
      say("Steps to deploy #{@system.name}")
      @system.steps.each_with_index do |ea, i|
        say("  #{i + 1}. #{ea.name}")
      end
    end

    def prompt_for_deploy_steps
      completed_steps = @deploy.progress.map {|ea| ea["step_id"] }

      @system.steps.each do |step|
        if completed_steps.include?(step.step_id)
          puts "✓ #{step.name}"
          next
        end

        action = choose(:continue, :fail_deploy) do |menu|
          menu.layout = :one_line
          menu.header = "Next step is #{step.name}. Select action"
          menu.prompt = " "
          menu.default = "continue"
        end

        case action
          when :fail_deploy
            say("Marking deploy as failed")
            @deploy.fail!
            return
          when :continue
            @deploy.progress_to(step.name)
        end
      end

      action = choose(:complete_deploy, :fail_deploy) do |menu|
        menu.layout = :one_line
        menu.header = "Select action"
        menu.prompt = " "
        menu.default = "complete_deploy"
      end

      case action
        when :complete_deploy then @deploy.complete!
        when :fail_deploy then @deploy.fail!
      end
    end

    def error_and_exit(msg)
      puts "Error: #{msg}"
      exit(1)
    end
  end
end