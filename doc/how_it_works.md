# How it works

## Software stack
- Database: [MongoDB](https://www.mongodb.com/what-is-mongodb)
- Web server: Apache
- Web application: [Laravel](https://laravel.com/) framework (PHP)
- [Docker](https://www.docker.com/why-docker) to run the database and the web application in contained environments

## Docker
By using Docker, nothing was installed directly on your system, except for Docker itself. For example, the database runs in a Docker container. A Docker container is just a Linux process which creates subprocesses for what it needs to run (the database). The web service runs in another Docker container. The two Docker containers communicate across a virtual private network. When importing data, a third container is temporarily created, running a Python script which connects to the Docker database container.
