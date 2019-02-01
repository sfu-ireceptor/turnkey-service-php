# iReceptor Service Turnkey (PHP)

A quick and easy way to build your own AIRR-seq repository.

## What is it?
- a database
- a web application exposing that database through the [iReceptor API](https://github.com/sfu-ireceptor/api)
- some scripts to load your data into the database

![iReceptor Service Turnkey Architecture](doc/architecture.png)

## How does it work?
Docker containers are used to make the installation and future updates clean and simple. For more information, see [How it works](doc/how_it_works.md).

## Installation
Get the code and launch the installation. It will take 10-30 min, depending on the download speed.
```
git clone https://github.com/sfu-ireceptor/turnkey-service-php.git
cd turnkey-service-php
scripts/install_turnkey.sh
```

## Check it's working

Go to <http://localhost/v2/samples> in your browser (if necessary, replace "localhost" with your server URL).

This returns the list of samples in your database by querying the web application at `/v2/samples`, which is an entry point of the [iReceptor API](https://github.com/sfu-ireceptor/api). An empty array `[]` is returned because the database is currently empty.

You can also use the command line:
```
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" "http://localhost/v2/samples"
```

## Loading data

#### General procedure
1. load the metadata associated with a study that has generated sequence data.
2. load the sequence annotations (from imgt, mixcr, etc).

#### Quick example: loading the test data

1. Load the metadata file [test_data/metadata_mixcr.csv](test_data/metadata_mixcr.csv):
```
scripts/load_metadata.sh test_data/metadata_mixcr.csv
```

To check it worked, go to <http://localhost/v2/samples> or execute:
```
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" "http://localhost/v2/samples"
```

2. Load the associated sequence annotations file [test_data/rearrangements_mixcr.txt](test_data/rearrangements_mixcr.txt):
```
scripts/load_rearrangements.sh mixcr test_data/rearrangements_mixcr.txt
```

To check it worked, go to <http://localhost/v2/sequences_summary> or execute:
```
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" "http://localhost/v2/sequences_summary"
```

Note: to load IMGT or AIRR annotations, replace the `mixcr` parameter by `imgt` or `airr`. Example:
```
scripts/load_rearrangements.sh imgt <IMGT file>
```

You can now [reset your turnkey](doc/resetting.md) and load your own data.


## More information
- [How it works](doc/how_it_works.md)
- [Troubleshooting](doc/troubleshooting.md) :hammer:
- [Moving the database to another folder](doc/moving_the_database_folder.md)
- [Updating the turnkey](doc/updating.md)
- [Resetting the turnkey database](doc/resetting.md)

## Contact us
:envelope: <support@ireceptor.org>
