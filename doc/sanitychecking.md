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
scripts/load_metadata.sh ireceptor /home/ubuntu/dataloading-curation/test/imgt/imgt_toy/PRJNA248411_Palanichamy_SRR1298740.csv
```
Then load the associated rearrangements (in IMGT VQuest format), check to see if the repertoire was loaded, and check the count of the number of rearrangements that were loaded for the repertoire.
```
scripts/load_rearrangements.sh imgt /home/ubuntu/dataloading-curation/test/imgt/imgt_toy/SRR1298740.txz
curl --data "{}" "http://localhost/airr/v1/repertoire"
curl --data '{"facets":"repertoire_id"}' "http://localhost/airr/v1/rearrangement"
```

### Perform a data provenance check

Performing a data provenance check given the above is straight forward using the `verify_dataload.sh` script.
```
scripts/verify_dataload.sh PRJNA248411 /home/ubuntu/dataloading-curation/test/imgt/imgt_toy PRJNA248411_Palanichamy_SRR1298740.csv vquest /tmp
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
########################################################################################################
---------------------------------------VERIFY FILES ARE HEALTHY-----------------------------------------

---------------------------------------------Metadata file----------------------------------------------

HEALTHY FILE: Proceed with tests

Existence and uniquenes of ir_rearrangement_number in metadata
TRUE: All entries under  ir_rearrangement_number  in master metadata are unique

---------------------------------------------API RESPONSE-----------------------------------------------

Existence and uniqueness of ir_rearrangement_number in API response
TRUE: ir_rearrangement_number found in API response

TRUE: ir_rearrangement_number unique in API response
```

Then the script will return information on the study title, authors and ID, and provide a count of the number of samples found in metadata and those successfully loaded into the Turnkey, as well as the number of those not found. In the example below half of the samples were successfully loaded and half were not. 

```
########################################################################################################
------------------------------------------HIGH LEVEL SUMMARY--------------------------------------------

Study title

Author 1, Author 2, Author 3

Study ID PRJNA12345

PRJNA12345 has a total of 40 entries
Entries found in API: 20
Entries not found in API: 20

```
The report will then summarize metadata field names and content. If the number uniquely identifying a sample is not found, it will raise a flag that looks as follows. 

```
########################################################################################################
-----------------------------------------DETAILED SANITY CHECK------------------------------------------

--------------------------BEGIN METADATA AND API FIELD AND CONTENT VERIFICATION-------------------------

ir_rearrangement_number: 645
JSON file index: []

The ir_rearrangement_number associated to this study was not found in API response

END OF ENTRY

-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
```

If on the other hand the sample is found, it will raise a TRUE flag if no content-related problems were found, otherwise information is provided on mismatches between the metadata file and the API response. This can come in handy when multiple versions of the same study are uploaded, if data has been modified since the first time it was loaded or if field names have been renamed since the first time they were loaded. The example below contains an instance of a field that was renamed with no content-related problems under all other field names. 

```
ir_rearrangement_number: 663
JSON file index: [532]

TEST: FIELD NAMES MATCH
RESULT --------------------------------------------------------------------------------->False

Summary of non-matching field names 

Field names in API response 

ir_other_rearrangement_file_name


Field names in Metadata 

ir_ancillary_rearrangement_file_name


TEST: FIELD CONTENT MATCHES
RESULT --------------------------------------------------------------------------------->TRUE 

END OF ENTRY

-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
```

The next entry contains a report on a field whose content does not match. 

```
ir_rearrangement_number: 1114
JSON file index: [140]

TEST: FIELD NAMES MATCH
RESULT --------------------------------------------------------------------------------->TRUE

TEST: FIELD CONTENT MATCHES
RESULT --------------------------------------------------------------------------------->FALSE 

Summary of non-matching entries 

ENTRY:  pub_ids
METADATA ENTRY RETURNS : PMID: 23556777  type: <class 'str'>
API RESPONSE RETURNS : PMCABCDS3 type: <class 'str'>

END OF ENTRY

-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
```

The last part of the report compares the number of sequences found in metadata, API response against the number of lines in the annotation files, for a given sample. It first ensures that files reported in metadata are found under the path provided. 

```
ir_rearrangement_number: 655
Metadata file names: ['SRR12345_a.txz', 'SRR12345_b.txz']
Files found in server: ['SRR12345_a.txz', 'SRR12345_b.txz']
Files not found in server: []

 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
ir_sequence_count 			#Lines Annotation F 	Test Result
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
API Resp 	 Metadata Resp
 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
540235 		 540235				540235			True

 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

Note that this check can work if one or more of the three components is missing. For example, if the sample is not loaded into the API, the script will report this as "NINAPI" and compare what is in the metadata against the number of lines in annotation file. If a filename is not found, it will be reported and a 0 will be marked under #Lines Annotation F. 

```
ir_rearrangement_number: 646
Metadata file names: ['SRR1964798.fmt19']
Files found in server: []
Files not found in server: ['SRR1964798.fmt19']

. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
ir_sequence_count 			#Lines Annotation F 	Test Result
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
API Resp 	 Metadata Resp
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
NINAPI 		 56075				0			False


 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 ```
