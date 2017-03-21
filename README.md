# Dev tools

These tools are meant for the pipeline workers. So instead of duplicating docker
containers, check out this repository. It will help you start the necessary
dependencies



RabbitMQ
========

`vagrant up rabbitmq --provider=docker`

The RabbitMQ will be on localhost:6672. The administrative interface on localhost:25672.


Database
========

`vagrant up db --provider=docker`

MongoDB is on localhost:37017, PostgreSQL on localhost:6432



Here are some useful commands:

- restart service

	`docker exec foo sv restart app`

- tail log from one of the workers

	`docker exec foo tail -f /app/logs/ClaimsImporter.log`
