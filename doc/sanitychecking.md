# Ensuring the data was loaded properly into the Turnkey

We provide a script that allows to verify that the data was loaded successfuly into the Turnkey. Quality assurance is performed on the following levels:

1) Count number of samples found in metadata against the number of samples found in API response for a given study ID
2) Ensure all samples are uniquely identified for a study in metadata and API response
3) Ensure field names and content match in metadata and API response
4) Ensure the number of sequences for each sample matches the annotation files contained in the server and that this number is in accordance to what the API response reports

## Switching to the development version

```
scripts/stop_turnkey.sh
cp scripts/.env-dev .env
scripts/start_turnkey.sh 
```

## How it works

The sanitychecking.py script takes as input the name of a CSV or EXCEL file containing sample metadata, the URL associated to the Turnkey, the study ID uniquely identifying the study, the full path to a directory containing annotation subdirectories for sequences processed using either MIXCR, IMGT or IGBLAST, followed by subdirectories for each, a check level (L,H,F) and a field name uniquely idenfitying each sample.


```
sanitychecking.py [-h]
                         metadata_file API_url_address study_id annotation_dir
                         imgt_subdir mixcr_subdir igblast_subdir sanity_level
                         unique_identifier
```



The turnkey will then use the development Docker Hub images, which are built from the developement branches of the GitHub repositories.


