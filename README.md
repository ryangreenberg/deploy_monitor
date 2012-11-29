# Deploy Monitor

[![Build Status](https://secure.travis-ci.org/ryangreenberg/deploy_monitor.png?branch=master)](https://travis-ci.org/ryangreenberg/deploy_monitor)

Deploy Monitor is a small web application for tracking the deploy process of your systems.

- Get an overview of active and recent deploys.
- Track statistics across deploys, like how long it takes to run tests
- Make sure two people aren't trying to deploy the same thing at the same time.
- Store arbitrary metadata about your deploys: the deployer's name, the release branch, comments, tickets--anything.

Deploy Monitor has a web UI and an API.

# Installation

1. Get the source. `git clone https://github.com/ryangreenberg/deploy_monitor.git`
2. Install the dependencies. `cd deploy_monitor && bundle install`
3. Configure the database. Edit `config.yml` and enter the connection details for a MySQL database. Run `sequel -m db/migrations mysql://<db_username>:<db_password>@localhost/<db_name>` to load the schema.
4. Start server with `rackup` or your preferred method of running Rack applications.

# Usage

## Initial Setup

You set up Deploy Monitor by creating *systems*, which are the things you deploy. Each system consists of a number of *steps* that are repeated for each deploy. Then you instrument your deploy process to update Deploy Monitor, letting it know how the steps are going.

### Creating Systems

This is currently no web UI for creating systems; use the API to create one:

    curl -X POST http://<deploy monitor host:port>/api/systems -d name=<name_of_system>

### Creating Steps

Each step has a name, which is used to identify the step in deploys, and a more friendly, readable description. Use the API to add steps to a system:

    curl -X POST http://<deploy monitor host:port>/api/systems/<name_of_system> -d name=javascript_tests -d "description=Jasmine JavaScript tests"

Steps are assigned numbers in the order they are created. You can edit a step later to change its description or number. See the API docs for examples.

### Instrument Your Deploy Process

Add code to your deploy process to do the following

```bash
# Tell Deploy Monitor to start the deploy
curl -X POST http://<deploy monitor host:port>/api/systems/<name_of_system>/deploys -d ""

# At the beginning of each of your steps, tell Deploy Monitor that the deploy
# has moved to the next step.
curl -X POST http://<deploy monitor host:port>/api/deploys/<deploy_id>/<step_name> -d ""
curl -X POST http://<deploy monitor host:port>/api/deploys/<deploy_id>/<next_step_name> -d ""
	
# If something goes wrong, tell Deploy Monitor that the deploy has failed
curl -X POST http://localhost:9292/api/deploys/<deploy_id>/complete -d result=failed

# Otherwise, at the end of the deploy, tell Deploy Monitor that it has
# completed successfully
curl -X POST http://localhost:9292/api/deploys/<deploy_id>/complete -d result=complete
```

## API

Deploy Monitor has a JSON API. See README_API.md for documentation on the available resources and operations.

# Development
Migrate: ./migrate
DB console: ./db_console