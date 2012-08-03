# Deploy Monitor API #

## Resources ##
- Systems
- Steps
- Deploys
- Progresses

## Overview ##

A system is an entity that is deployed repeatedly. To create a new system, POST to /systems with the param name.

Steps are the stages of deploying a system. You will likely want to include the steps to prepare your deploy, like running tests. To create a step, POST to /:system_name/steps with name, description, and number.

To start a deploy, POST to /:system_name/deploys. This will return HTTP 201 and a deploy object if successful. If there is already an active deploy for this system, the response will be HTTP 400.

To advance a deploy to another step, POST to /deploys/:deploy_id/step/:step_name. This will return HTTP 201 if successful, or HTTP 400 if the provided step does not exist. When advancing to a new step, the previous progress is marked as complete.

To complete a deploy, POST to /deploys/:deploy_id/complete. You can provide a `result`, which can be complete or failed. The default is complete.

New systems and deploy steps will be created when a deploy is created for an unknown system, or advanced to an unknown step. If you want to disable this feature, change the config values for implicit_system_creation and implicit_step_creation.

## API Endpoints ##

### `GET /systems`
List known systems

### `POST /systems`
Create a new system

Params: name

### `GET /:system_name/steps`
List the steps to deploy the given system

### POST `/:system_name/steps`
Create a new step for the given system

Params: name, description, number

### `GET /steps/:step_id`
Get the given deploy step

### `PUT /steps/:step_id`
Update the given deploy step

Params: name, description, number

### `GET /:system_name/deploys`
List the deploys for the given system

Params: active (true|false)

### `POST /:system_name/deploys`
Create a new deploy for the given system. Will return HTTP 400 if a deploy for this system is already active.

### `GET /deploys/:deploy_id`
Get the given deploy

### `PUT /deploys/:deploy_id`
Update the given deploy

Params: any arbitrary data can be associated with a deploy. Put the string "null" to delete the data. For example:

    PUT /deploys/10 ticket=APP-123&owner=alice&color=null

### `POST /deploys/:deploy_id/step/:step_name`
Advance the deploy to the given step

### `POST /deploys/:deploy_id/complete`
Finish the given deploy

Params: result (complete|failed)