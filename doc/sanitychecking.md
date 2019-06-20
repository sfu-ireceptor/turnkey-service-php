# Ensuring the data was loaded properly into the Turnkey

We provide a script that allows to verify that the data was loaded successfuly into the Turnkey. Quality assurance is performed on the following levels:

1) Count number of samples found in metadata against the number of samples found in API response for a given study ID
2) Ensure all samples are uniquely identified for a study in metadata and API response
3) Ensure field names and content match in metadata and API response
4) Ensure the number of sequences for each sample matches the annotation files contained in the server and that this number is in accordance to what the API response reports


## How it works

The sanitychecking.py script takes as input:

* the name of a CSV or EXCEL file containing sample metadata
* the URL associated to the Turnkey
* the study ID uniquely identifying the study
* the full path to a directory containing annotation subdirectories for sequences processed using either MIXCR, IMGT or 
IGBLAST
* IMGT subdirectory
* MIXCR subdirectory
* IGBLAST subdirectory
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
  annotation_dir     Full path to directory containing annotation
                     subdirectories for IMGT, MIXCR and IGBLAST annotations.
  imgt_subdir        Subdirectory found within annotations directory
                     containing IMGT annotations only.
  mixcr_subdir       Subdirectory found within annotations directory
                     containing MIXCR annotations only.
  igblast_subdir     Subdirectory found within annotations directory
                     containing IGBLAST annotations only.
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
python sanitychecking.py "./cancer_data_and_papers/PRJEB1234_metadata_2019-05-31.xlsx" http://ipa5.ireceptor.org/v2/samples 'PRJEB1234' '/PATH/TO/ANNOTATION/SUBDIRECTORIES/' "IMGT_FILES/" "MIXCR_FILE/" "IGBLAST_FILES/" "LHF" "unique_sample_ID"
```



