# iReceptor Service Turnkey (PHP)

A quick and easy way to build your own AIRR-seq repository.

## What is it?
- a database with scripts to load data into it
- a web application exposing that database through the [iReceptor API](https://github.com/sfu-ireceptor/api)

## Installation (15 min)
Get the code and launch the installation:
```
git clone https://github.com/sfu-ireceptor/turnkey-service-php.git
cd turnkey-service-php
./install.sh
```

#### Check it's working
See the list of samples in your database at the `/v2/samples` entry point of the iReceptor API:  go to <http://localhost/v2/samples"> in your browser (if necessary, replace "localhost" with your server URL).
You can also use the command line:
```
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" "http://localhost/v2/samples"
```


An empty array is returned because the database is currently empty.
```
[]
```


## Loading data

#### Procedure
1. load the "sample metadata" associated with a study that has generated sequence data.
2. load the sequence annotations (from imgt, mixcr, etc).

#### Example: loading the test data

1. Load the samples:
```
./load_samples.sh data/samples.csv 

```

Check it worked: go to <http://localhost/v2/samples"> or execute:
```
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" "http://localhost/v2/samples"
```

## Reference
- <http://ireceptor.org>
- [Credits](docs/credits.md)
- Contact us at <support@ireceptor.org>
