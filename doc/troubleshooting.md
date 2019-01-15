# Troubleshooting

## Logging into the MongoDB database of the database Docker container
```
scripts/mongo.sh
```

You can then execute standard MongoDB commands:
```
// show sampless
db.samples.find()

// show sequence annotations
db.sequences.find()
```

For more, see the [MongoDB documentation](https://docs.mongodb.com/manual/tutorial/query-documents/)


## Starting and stopping the Turnkey
This will start and stop the Docker containers.
```
scripts/start_turnkey.sh
```
```
scripts/stop_turnkey.sh
```

## See the running Docker containers
You can use docker-compose:
```
sudo docker-compose --file scripts/docker-compose.yml --project-name turnkey-service ps
```
which will return the list of services (those services are defined in scripts/docker-compose.yml):
```
                 Name                                Command               State          Ports       
------------------------------------------------------------------------------------------------------
turnkey-service_ireceptor-api_1           docker-php-entrypoint apac ...   Up       0.0.0.0:80->80/tcp
turnkey-service_ireceptor-database_1      docker-entrypoint.sh mongod      Up       27017/tcp         
turnkey-service_ireceptor-dataloading_1   python3                          Exit 0     
```

or directly Docker:
```
sudo docker ps
```
which will return the list of Docker containers currently running:
```
CONTAINER ID        IMAGE                                   COMMAND                  CREATED             STATUS              PORTS                NAMES
9641ed06f008        ireceptorj/service-php-mongodb:latest   "docker-php-entrypoi…"   3 hours ago         Up 3 hours          0.0.0.0:80->80/tcp   turnkey-service_ireceptor-api_1
0265683d92cd        ireceptorj/repository-mongodb:dev       "docker-entrypoint.s…"   3 hours ago         Up 3 hours          27017/tcp            turnkey-service_ireceptor-database_1
```

## Logs

### View the database log (MongoDB log)
```
sudo docker-compose --file scripts/docker-compose.yml --project-name turnkey-service logs ireceptor-database
```

### View the web application log (Apache log)
```
sudo docker-compose --file scripts/docker-compose.yml --project-name turnkey-service logs ireceptor-api
```

### View the dataloading logs (logs of the data import Python script)
Look into the `logs` folder:
```
ls -l logs
```
which contains a log file for each file imported into the database.
```
total 28
-rw-rw-r-- 1 ubuntu ubuntu 486 Jan 12 02:00 2019-01-12_02-00-53_metadata_mixcr.csv.log
-rw-rw-r-- 1 ubuntu ubuntu 563 Jan 12 02:01 2019-01-12_02-01-01_rearrangements_mixcr.txt.log
-rw-rw-r-- 1 ubuntu ubuntu 563 Jan 12 02:01 2019-01-12_02-01-07_rearrangements_mixcr.txt.log
-rw-rw-r-- 1 ubuntu ubuntu 762 Jan 14 21:46 2019-01-14_21-46-52_metadata_mixcr.csv.log
-rw-rw-r-- 1 ubuntu ubuntu 541 Jan 14 21:48 2019-01-14_21-48-08_metadata_mixcr.csv.log
-rw-rw-r-- 1 ubuntu ubuntu 550 Jan 14 21:48 2019-01-14_21-48-44_rearrangements_mixcr.txt.log
-rw-rw-r-- 1 ubuntu ubuntu 549 Jan 14 21:51 2019-01-14_21-51-04_rearrangements_mixcr.txt.log
```
