# iReceptor Turnkey

Create an [AIRR-seq data](https://www.nature.com/articles/ni.3873) repository within minutes. 

See the [iReceptor Turnkey](http://www.ireceptor.org/repositories#turnkey) section of the [iReceptor website](http://www.ireceptor.org/) for more information.

The remainder of this document only provides some technical details and the installation procedure. 

## What is the iReceptor Turnkey?
- a database
- scripts to load your data into the database
- a web service exposing the database using the [AIRR Data Commons (ADC) API](https://docs.airr-community.org/en/latest/api/adc_api.html), allowing immediate integration into the [AIRR Data Commons](https://docs.airr-community.org/en/latest/api/adc.html#datacommons).

These components live in Docker containers. This makes the installation quick and future updates easy. For more details, see [How it works](doc/how_it_works.md).

## Installation

```
# download the code from the stable production-v3 branch
git clone --branch production-v3 https://github.com/sfu-ireceptor/turnkey-service-php.git

# launch the installation script.
# note: Docker images will be downloaded from DockerHub. This can take up to 30 minutes.
cd turnkey-service-php
scripts/install_turnkey.sh
```

## Check it's working

```
# if necessary, replace "localhost" with your server URL:
curl --data "{}" "http://localhost/airr/v1/repertoire"
```

This returns the list of repertoires in your database by querying the web service at `/airr/v1/repertoire`, which is an entry point of the [AIRR Data Commons (ADC) API](https://docs.airr-community.org/en/latest/api/adc_api.html).


You can also go to <http://localhost> in your browser (replace "localhost" with your server URL if necessary). You should see the home page for your repository, with information about the ADC API and iReceptor.


## Loading data

#### The general procedure to load a study that has generated sequence data
1. load the associated repertoire metadata (using the iReceptor metadata TSV format)
2. load the sequence annotations (from imgt, mixcr, etc).

#### Quick example: loading the test data
The test data is a single repertoire containing 1000 rearrangments. Source: [The Different T-cell Receptor Repertoires in Breast Cancer Tumors, Draining Lymph Nodes, and Adjacent Tissues](https://www.ncbi.nlm.nih.gov/pubmed/28039161).

1. Load the repertoire metadata file [test_data/PRJNA330606_Wang_One_Sample.csv](test_data/PRJNA330606_Wang_One_Sample.csv).
```
scripts/load_metadata.sh ireceptor test_data/PRJNA330606_Wang_One_Sample.csv
```

To check it worked, execute:
```
curl --data "{}" "http://localhost/airr/v1/repertoire"
```

This should return the repertoire metadata as JSON.

2. Load the sequence annotations [test_data/SRR4084215_aa_mixcr_annotation_1000_lines.txt.gz](test_data/SRR4084215_aa_mixcr_annotation_1000_lines.txt.gz):
```
scripts/load_rearrangements.sh mixcr test_data/SRR4084215_aa_mixcr_annotation_1000_lines.txt.gz
```

To check it worked execute the following command:
```
curl --data "{}" "http://localhost/airr/v1/rearrangement"
```
This should result in a JSON repsonse with all of the sequence rearrangement data for the 1000 sequences in the data file.

Note: to load IMGT or AIRR annotations, replace the `mixcr` parameter by `imgt` or `airr`. Example:
```
scripts/load_rearrangements.sh imgt <IMGT file>
```

Congratulations :relaxed: You can now [reset the turnkey database](doc/resetting.md) and load your own data.

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
