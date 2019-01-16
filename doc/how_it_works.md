# How it works

## Software stack
- Database: [MongoDB](https://www.mongodb.com/what-is-mongodb)
- Web server: Apache
- Web application: [Laravel](https://laravel.com/) framework (PHP)
- [Docker](https://www.docker.com/why-docker) to run the database and the web application in contained environments

## Docker
Nothing is installed directly on your machine, except for Docker. The database and the web application run in Docker containers, which are plain Linux processes creating subprocesses for what it needs to run (the database and the web application). The two Docker containers communicate across a virtual private network. When importing data, a third Docker container is temporarily created, running a Python script which sends data to the Docker database container.

![iReceptor Service Turnkey Docker containers](docker_containers.png)
