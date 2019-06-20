# Ensuring the data was loaded successfully into the Turnkey

Due to the dimensions of the metadata and the number of steps involved in curating and loading data, the overall process can be prone to error. We provide a script that allows to verify that the data was loaded successfuly into the Turnkey. Quality assurance is performed on the following levels:

1) Count number of samples found in metadata against the number of samples found in API response for a given study ID
2) Ensure all samples are uniquely identified for a study in metadata and API response
3) Ensure field names and content match in metadata and API response
4) Ensure the number of sequences for each sample matches the annotation files contained in the server and that this number is in accordance to what the API response reports


## How it works

The sanitychecking.py script takes as input:

* the name of a CSV or EXCEL file containing sample metadata
* the URL associated to the Turnkey
* the study ID uniquely identifying the study
* the full path to a directory containing annotation files for sequences processed using either MIXCR, IMGT or 
IGBLAST
* a sanity check level: "H" for summary on number of samples loaded, "L" for details on field name and content, "F" for number of sequences check 
* a field name within the metadata uniquely idenfitying each sample


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
  sanity_level       This option let's you choose the level: H for short
                     summary, L for details on field name and content, F for
                     details on number of lines in annotation files against
                     what is found both in metadata spreadsheet and API
                     response.
  unique_identifier  Choose a field name from the sample metadata spreadsheet
                     which UNIQUELY identifies each sample.

optional arguments:
  -h, --help         show this help message and exit

```
## Sample Usage

```
python sanitychecking.py /PATH_TO_METADATA_FILE/PRJEB1234_metadata_2019-05-31.xlsx http://ipa5.ireceptor.org/v2/samples PRJEB1234 /PATH/TO/ANNOTATION/SUBDIRECTORIES/ LHF unique_sample_ID
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

. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
				ir_sequence_count 			#Lines Annotation F 	Test Result
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
				API Resp 	 Metadata Resp
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
				540235 		 540235				540235			True


 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

Note that this check can work if one of the three components is missing. For example, if the sample is not loaded into the API, the script will report this as "NINAPI" and compare what is in the metadata against the number of lines in annotation file. 

```
ir_rearrangement_number: 646
Metadata file names: ['SRR1964798.fmt19']
Files found in server: ['SRR1964798.fmt19']
Files not found in server: []

. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
				ir_sequence_count 			#Lines Annotation F 	Test Result
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
				API Resp 	 Metadata Resp
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
				NINAPI 		 56075				56075			False


 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ```
