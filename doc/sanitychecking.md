# Ensuring the data was loaded successfully into the Turnkey

Due to the dimensions of the metadata and the number of steps involved in curating and loading data, the overall process can be prone to error. We provide a script that allows the user to verify that the data was loaded successfuly into the Turnkey. Quality assurance is performed on the following levels:

1) Count number of repertoires found in metadata CSV file against the number of repertoires found in API response, given a study ID
2) Ensure all repertoires are uniquely identified for a study in metadata file and API response
3) Ensure field names and content match in metadata and API response
4) Compare the total number of lines found within the annotation files against the number of sequences in the API response. It can also compare this number against what is found within the metadata file. Please ensure to name this field as ir_curator_count in the metadata CSV file to perform this comparison. 


## How it works

The verify_dataload.sh script takes as input:

* the study ID uniquely identifying the study
* the full path to a directory containing the study data (metadata file and annotation files) 
* the name of a CSV file containing sample metadata
* the type of data being processed (either MIXCR, IMGT or AIRR)
* the directory in which to store the output report


And as output it generates a report covering points 1-4. 

## Positional arguments:

```

  study_id           String value uniquely identifying study. Example:
                     PRJEB1234, PRJNA1234.
  study_dir          Full path to directory containing the study metadata and 
                     annotation files for sequences processed
  metadata_file      The CSV file containing sample metadata for a
                     study.
  annotation_tool    The file format used to store the annotated sequence
                     data, either vquest, mixcr, or airr.
  output_dir         The directory in which to store the output of the data
                     provenance report.

optional arguments:
  -h, --help         show this help message and exit

```
## Sample Usage

A working example using sample metadata from the [iReceptor Curation github repository](https://github.com/sfu-ireceptor/dataloading-curation) is given below. The example assumes you have a working iReceptor Turnkey installed, the iReceptor Turnkey has been installed in $HOME/turnkey-service-php, and that it is possible to load data into this repository (the repository is experimental and the data can later be deleted).

### Checkout the curation data from Github.

The example below assumes we are storing the data curation github in the users $HOME directory.

```
cd $HOME
git clone https://github.com/sfu-ireceptor/dataloading-curation.git
```
We now have a set of test data sets available for experimentation.

### Load a data set into the iReceptor Turnkey

We will use a IMGT VQuest based data set for our test, in particular a small "toy" data set. This is stored in $HOME/dataloading-curation/test/imgt/imgt_toy. The `verify_dataload.sh` script assumes that all data from the study are in a single directory, and this study follows that protocol. The toy data set is a subset of the data from Palanichamy et al with Study ID PRJNA248411.

First load the study metadata. The "toy" IMGT study only has one repertoire.
```
cd $HOME/turnkey-service-php
scripts/load_metadata.sh ireceptor $HOME/dataloading-curation/test/imgt/imgt_toy/PRJNA248411_Palanichamy_SRR1298740.csv
```
Then load the associated rearrangements (in IMGT VQuest format), check to see if the repertoire was loaded, and check the count of the number of rearrangements that were loaded for the repertoire.
```
scripts/load_rearrangements.sh imgt $HOME/dataloading-curation/test/imgt/imgt_toy/SRR1298740.txz
curl --data "{}" "http://localhost/airr/v1/repertoire"
curl --data '{"facets":"repertoire_id"}' "http://localhost/airr/v1/rearrangement"
```

### Perform a data provenance check

Performing a data provenance check given the above is straight forward using the `verify_dataload.sh` script.
```
scripts/verify_dataload.sh PRJNA248411 $HOME/dataloading-curation/test/imgt/imgt_toy PRJNA248411_Palanichamy_SRR1298740.csv vquest /tmp
```
This will provide a report in the output directory provided (/tmp in this case). The output of the command will report on several test phases:
- It will check the metadata file provided and warn of any errors.
- It will report on any fields that are expected in the API and are missing
- It will report on any curatore fields that are expected in the metadata file and are missing
- It will report on any discrepancies between the content of data fields in the metadata file and those returned by the API
- It will report on any discrepancies between sequences counts that are returned from the API (and therefore the repository), those that were in the original file that was loaded, and the count in the internal iReceptor metadata field (ir_curator_count) in the metadata file.

A summary of potential issues will be provided, with detailed reports in the following files in the output directory (/tmp)
- PRJNA248411_Facet_Count_curator_count_Annotation_count_DATETIME.csv
- PRJNA248411_reported_fields_DATETIME.csv

## Check the sample report output

The script will generate a report covering each level above. It will first ensure that the file provided is not corrupt and that all samples are uniquely identified. In the sample below, the metadata file was healthy and all samples were identified uniquely.

```
DATA PROVENANCE TEST

--------------------------------------------------------------------------------------------------------
Check Metadata file

PASS: Metadata file /study/PRJNA248411_Palanichamy_SRR1298740.csv loaded
```
The test then checks the AIRR Mapping file, which specifies expected fields for both API response and
data curation fields, against fields in the API response and in the metadata file.
```
--------------------------------------------------------------------------------------------------------
Check AIRR Mapping against API and Metadata file

INFO: Sending query to http://ireceptor-api//airr/v1/repertoire
INFO: Total query time (in seconds): 0.2084512710571289

INFO: Checking field names from AIRR mapping for API (column ir_adc_api_response) not found in API response
PASS: No fields missing

INFO: Checking field names in AIRR mapping for curation (column ir_curator) not found in metadata fields
PASS: No fields missing
```
The test then checks that the data in the fields in the API response match the data in the metadata file. 
This performs a field to field comparison, across all repertoires. If the test finds any field content
differences it reports a summary and writes out the details in specified file.

Note: The data verification currently has problems comparing the content in fields that contains arrays
of strings. So it is expected to have content differences flagged for two AIRR array fields, `study.keywords_study`
and `data_processing.data_processing_files`. These fields should be checked for errors, but in general messages like
the ones below are expected.
```
--------------------------------------------------------------------------------------------------------
Metadata/API content cross comparison

WARN: Some fields may require attention:
WARN:     In ADC API:  ['study.keywords_study' 'data_processing.0.data_processing_files']
WARN:     In metadata:  ['keywords_study' 'data_processing_files']
WARN: For details refer to /output/PRJNA248411_reported_fields_2021-07-28 21:01:56.525629.csv
```
The data verification then checks to confirm the validity of the AIRR API response.
```
--------------------------------------------------------------------------------------------------------
AIRR field validation

INFO: Sending query to http://ireceptor-api//airr/v1/repertoire
INFO: Total query time (in seconds): 0.20888471603393555
PASS: AIRR Repertoire is valid
```
The last step is the most processing intensive. In this step, the data verification request the ADC API
to count the rearrangements for a repertoire and confirms that that number matches both the number of
rearrangements in the file that was loaded for the repertoire as well as the curator count field (ir_curator_count)
in the metadata file.
```
--------------------------------------------------------------------------------------------------------
Annotation count validation (API, file size, curator count)

INFO: Processing annotations for Repertoire 393 using:
INFO:   annotation_file_format: vquest
INFO:   ir_rearrangement_tool: IMGT high-Vquest
INFO: Sending query to http://ireceptor-api//airr/v1/rearrangement
INFO: Total query time (in seconds): 0.22046279907226562
PASS: Repertoire 393 returned TRUE (test passed), see CSV for details
```
