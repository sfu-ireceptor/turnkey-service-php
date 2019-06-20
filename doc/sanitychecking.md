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


```
sanitychecking.py [-h]
                         metadata_file API_url_address study_id annotation_dir
                         imgt_subdir mixcr_subdir igblast_subdir sanity_level
                         unique_identifier
```




