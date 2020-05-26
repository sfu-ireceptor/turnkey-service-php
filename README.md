# iReceptor Turnkey

The iReceptor Turnkey is a quick and easy mechanism for researchers to create their own [AIRR Data Commons](https://docs.airr-community.org/en/latest/api/adc.html#datacommons) repository.

## What's in the iReceptor Turnkey?
- a database
- scripts to add data to the database
- a web service exposing the database via the [ADC API](https://docs.airr-community.org/en/latest/api/adc_api.html)

These components are packaged as Docker images. The installation script will download and run these images, after having installed Docker.

[Read more about the iReceptor Turnkey](http://www.ireceptor.org/repositories#turnkey) on the iReceptor website. The remainder of this document only provides installation instructions.

## System requirements

- Linux Ubuntu. The turnkey was tested on Ubuntu 16.04 and 18.04.
- `sudo` without password. It's usually already enabled on virtual machines.

## Installation

Download the code from the `production-v3` branch:

```
git clone --branch production-v3 https://github.com/sfu-ireceptor/turnkey-service-php.git
```

Launch the installation script. Note: multiple Docker images will be downloaded from DockerHub. Total time estimate: 10-30 min.

```
cd turnkey-service-php
scripts/install_turnkey.sh
```

## Check it's working

```
curl --data "{}" "http://localhost/airr/v1/repertoire"
```

This returns the list of repertoires in your database, by querying the web service at `/airr/v1/repertoire`, an [ADC API](https://docs.airr-community.org/en/latest/api/adc_api.html) entry point.


You can also visit <http://localhost> in your browser (replace "localhost" with your server URL if necessary). You'll see the home page for your repository, with information about the ADC API and iReceptor.


## Loading data
The general data loading procedure, for a study which has generated sequence data is to:
1. load the associated repertoire metadata (using the [iReceptior Metadata CSV format](https://github.com/sfu-ireceptor/dataloading-curation/tree/master/metadata))
2. load the sequence annotations (from IMGT, MiXCR, etc)

## Loading the test data
Load the included test data to familiarize yourself with the data loading procedure. You will delete that test data afterwards.

Note: the test data is a single repertoire with 1000 rearrangments. It's a subset from the study [The Different T-cell Receptor Repertoires in Breast Cancer Tumors, Draining Lymph Nodes, and Adjacent Tissues](https://www.ncbi.nlm.nih.gov/pubmed/28039161) data.

1. **Load the repertoire metadata file** [test_data/PRJNA330606_Wang_1_sample_metadata.csv](test_data/PRJNA330606_Wang_1_sample_metadata.csv).
```
scripts/load_metadata.sh ireceptor test_data/PRJNA330606_Wang_1_sample_metadata.csv
```

Check it worked:
```
curl --data "{}" "http://localhost/airr/v1/repertoire"
```
The repertoire metadata is returned as JSON.

2. **Load the sequence annotations file** [test_data/SRR4084215_aa_mixcr_annotation_1000_lines.txt](test_data/SRR4084215_aa_mixcr_annotation_1000_lines.txt):
```
scripts/load_rearrangements.sh mixcr test_data/SRR4084215_aa_mixcr_annotation_1000_lines.txt
```

Check it worked:
```
curl --data "{}" "http://localhost/airr/v1/rearrangement"
```
All of the rearrangement data for the 1000 sequences is returned as JSON.

Note: both scripts `load_metadata.sh` and `load_rearrangement.sh` produce a log file for each file processed in the `log` directory. Log files are named using the current date, followed by the name of the processed file.

That's all, congratulations :relaxed: You can now [reset the turnkey database](doc/resetting.md) and load your own data.

## Loading your own data

Note: use a clearly defined curation process for your data to endure good provenance. Refer to the [iReceptor Curation](http://www.ireceptor.org/curation) process and the [iReceptor Curation GitHub repository](https://github.com/sfu-ireceptor/dataloading-curation/tree/master) for recommended data curation approaches.

To load your own data, follow the same procedure as with the test data.

1. Load your repertoire metadata:
```
scripts/load_metadata.sh ireceptor <file path of your CSV metadata file>
```

2. Load your sequence annotations file(s). You can load multiple files at once: 
```
scripts/load_rearrangements.sh mixcr <your study data folder>/*.txt
```
This will load all files ending by `.txt` from your study data folder.

Note: Compressed `.gz` files are supported and can be loaded directly. Example:
```
scripts/load_rearrangements.sh mixcr <your study data folder>/*.gz
```

### Loading IMGT or AIRR sequence annotations

Just replace the `mixcr` parameter by `imgt` or `airr`. Example:
```
scripts/load_rearrangements.sh imgt <IMGT files>
```


### Loading many sequence annotations
:warning: Loading many sequence annotations can take hours. We recomend using the Unix command `nohup` to run the script in the background, and to redirect the script output to a log file. So you can log out and come back later to check on the data loading progress by looking at that file. Example:

```
nohup scripts/load_rearrangements.sh mixcr my_study_folder/*.txt > progress.log &
```


## Backing up the database
When you've loaded your data, we recommend [backing up the database](doc/database_backup.md) to avoid having to load your data again in case a problem happens.

## Other information

### Managing the database
- [Moving the database to another folder](doc/moving_the_database_folder.md)
- [Backing up and restoring the database](doc/database_backup.md)
- [Resetting the turnkey database](doc/resetting.md)

### Managing the turnkey
- [How the turnkey works](doc/how_it_works.md)
- [Updating the turnkey](doc/updating.md)
- [Web statistics](doc/web_stats.md)

### When something's wrong
- [Troubleshooting](doc/troubleshooting.md) :hammer:

## Contact us
:envelope: <support@ireceptor.org>
