# Using the turnkey developement version

Warning: this is an unstable version, you might lose your data and encounter some serious bugs.

## Switching to the development version

```
scripts/stop_turnkey.sh
cp scripts/.env-dev .env
scripts/start_turnkey.sh 
```

## How it works:


The .env file overrides the default Docker image tags defined in scripts/docker-compose.yml:

```
DATABASE_TAG=dev
API_TAG=latest
DATALOADING_TAG=latest
```

The turnkey will then use the development Docker Hub images, which are built from the developement branches of the GitHub repositories.


## Switching back to the production version

```
scripts/stop_turnkey.sh
rm .env
scripts/start_turnkey.sh 
```
