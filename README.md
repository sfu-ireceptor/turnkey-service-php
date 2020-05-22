# iReceptor Turnkey

The iReceptor Turnkey is a quick and easy mechanism for researchers to create their own [AIRR Data Commons](https://docs.airr-community.org/en/latest/api/adc.html#datacommons) repository.

## What's in the iReceptor Turnkey?
- a database
- scripts to add data to the database
- a web service exposing the database via the [ADC API](https://docs.airr-community.org/en/latest/api/adc_api.html)

These components are encapsulated in Docker images. The installation script will download and run these images, after having installed Docker.

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
1. load the associated repertoire metadata (using our metadata CSV format)
2. load the sequence annotations (from imgt, mixcr, etc)

## Loading the test data
Load the included test data to familiarize yourself with the data loading procedure. You will be able to delete that test ßdata afterwards.

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

2. **Load the sequence annotations file** [test_data/SRR4084215_aa_mixcr_annotation_1000_lines.txt.gz](test_data/SRR4084215_aa_mixcr_annotation_1000_lines.txt.gz):
```
scripts/load_rearrangements.sh mixcr test_data/SRR4084215_aa_mixcr_annotation_1000_lines.txt.gz
```

Check it worked:
```
curl --data "{}" "http://localhost/airr/v1/rearrangement"
```
All of the rearrangement data for the 1000 sequences is returned as JSON.

That's all, congratulations :relaxed: You can now [reset the turnkey database](doc/resetting.md) and load your own data.

## Loading large data sets

The above scripts can be used to load large data sets. In particular, the load_rearrangements.sh script can be used to load many rearrangement files in a row. We recommend following a well structured data curation process to help ensure data provenance around your data management. Please refer to the [iReceptor Curation](http://www.ireceptor.org/curation) process and the [iReceptor Curation GitHub repository](https://github.com/sfu-ireceptor/dataloading-curation/tree/master) for more information on recommended data curation approaches.

Assuming all data for a study can be found in a single directory, it is possible to utilize the two commands described above to load the entire study data. Assuming your data is in a folder called STUDY_DATA, the study metadata is stored in a metadata file called METADATA.csv, and all of your rearrangement files are MiXCR .txt files, you can do the following:

1. To load your Repertiore Metadata use the load_metadata.sh scrip as above:

```
scripts/load_metadata.sh ireceptor STUDY_FOLDER/METADATA.csv
```

2. To load your rearrangement data, use the load_rearrangements.sh as given below:

```
scripts/load_rearrangements.sh mixcr STUDY_FOLDER/*.txt
```

Note: to load IMGT or AIRR annotations, replace the `mixcr` parameter by `imgt` or `airr`, for example:
```
scripts/load_rearrangements.sh imgt <IMGT file>
```

It is important to note that depending on the size of the data in your rearrangement files, loading the rearrangements can take a very long time. As a result, it is good practice to use the Unix "nohup" command to control the rearrantement loading. The Unix nohup command allows you to run a long running command in the background, redirects the output of that command to a file, and allows you to log out and come back to check on the progress of your command later. You would use the nohup command as follows:
```
nohup scripts/load_rearrangements.sh mixcr STUDY_FOLDER/*.txt > rearrangement.log &
```
Also note that both the load_metadata.sh and the load_rearrangement.sh command produce log files for every file that they process. If you want to view the log files simply refere to the files in the log directory. Log files are named using date and the file that was processed.

## Maintenance
When your data is loaded, make sure to [back up the database](doc/database_backup.md) to avoid going through the loading process again if a problem happens.  

## More information
- [How it works](doc/how_it_works.md)
- [Troubleshooting](doc/troubleshooting.md) :hammer:
- [Backing up and restoring the database](doc/database_backup.md)
- [Moving the database to another folder](doc/moving_the_database_folder.md)
- [Updating the turnkey](doc/updating.md)
- [Resetting the turnkey database](doc/resetting.md)
- [Web statistics](doc/web_stats.md)

## Contact us
:envelope: <support@ireceptor.org>
