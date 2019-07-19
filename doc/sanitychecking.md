# Ensuring the data was loaded successfully into the Turnkey

Due to the dimensions of the metadata and the number of steps involved in curating and loading data, the overall process can be prone to error. We provide a script that allows to verify that the data was loaded successfuly into the Turnkey. Quality assurance is performed on the following levels:

1) Count number of samples found in metadata CSV or EXCEL file against the number of samples found in API response, given a study ID
2) Ensure all samples are uniquely identified for a study in metadata file and API response
3) Ensure field names and content match in metadata and API response
4) Compare the total number of lines found within the annotation files against the number of sequences in the API response. It can also compare this number against what is found within the metadata file. Please ensure to name this field as ir_curator_count in the metadata CSV or EXCEL file to perform this comparison. 


## How it works

The verify_dataload.sh script takes as input:

* the name of a CSV or EXCEL file containing sample metadata
* the URL associated to the Turnkey
* the study ID uniquely identifying the study
* the full path to a directory containing annotation files for sequences processed using either MIXCR, IMGT or 
IGBLAST
* a field name within the metadata uniquely idenfitying each sample

And as output it generates a report covering points 1-4. 

## Positional arguments:

```
  metadata_file      The EXCEL or CSV file containing sample metadata for a
                     study.
  API_url_address    The URL associated to your Turnkey, or the URL associated
                     to the API containing sample metadata.
  study_id           String value uniquely identifying study. Example:
                     PRJEB1234, PRJNA1234.
  annotation_dir     Full path to directory containing annotation files for
                     sequences processed using either IMGT, MIXCR and IGBLAST
                     annotations.
  unique_identifier  Choose a field name from the sample metadata spreadsheet
                     which UNIQUELY identifies each sample.

optional arguments:
  -h, --help         show this help message and exit

```
## Sample Usage

An example with positional arguments

```
verify_dataload.sh /PATH/TO/metadata_file API_url_address study_id annotation_dir unique_identifier
```
A working example using sample metadata from the [iReceptor Curation github repository](https://github.com/sfu-ireceptor/dataloading-curation) is given below. This assumes:
- the repertoire metadata and the rearrangments exists in the same directory as per the [iReceptor Curation process](http://www.ireceptor.org/curation). In this case the files from the dataloading_curation github test data set in dataloading-curation/test/imgt/imgt are used. This test data set is from Palanichamy et al with Study ID PRJNA248411.
- the study above has been loaded into your iReceptor Turnkey at URL http://your.repository.org/v2/samples using the Turnkey data loading process.
- a unique identifier field name ir_rearrangement_number was used when the study was loaded (this identifier exists in the repertoire metadata file provided with the above study).

You can download this example dataset from the github repository above. Once downloaded and loaded into your repository, the data loading process can be verified with the command below:

```
verify_dataload.sh dataloading-curation/test/imgt/imgt/PRJNA248411_Palanichamy_2018-12-18.csv http://your.repository.org/v2/samples PRJNA248411 dataloading-curation/test/imgt/imgt ir_rearrangement_number
```

## Sample check report output

Provided all arguments are in place, and all HLF options are asked for in the sanity_level option, the script will generate a report covering each level. It will first ensure that the file provided is not corrupt and that all samples are uniquely identified. In the sample below, the metadata file was healthy and all samples were identified uniquely via the field name "ir_rearrangement_number
".

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
