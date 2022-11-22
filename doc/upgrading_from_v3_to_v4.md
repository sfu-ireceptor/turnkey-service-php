# Upgrading your turnkey from v3 to v4

There are two steps to upgrading an iReceptor Turnkey repository from v3 to v4. First it is necessary to upgrade the software itself, and this is done through the normal iReceptor Turnkey upgrade process. The second step is to update the data in the repository itself. This second step is necessary because v4 of the iReceptor Turnkey supports the AIRR Community v1.4 standard, and in this standard some of the AIRR fields have changed. These update processes are described below.

## Upgrading the iReceptor Turnkey software

This is relatively straight forward, and follows the normal iReceptor Turnkey upgrade process.

### Stop the turnkey
```
scripts/stop_turnkey.sh
```

### Switch to the Git branch production-v4
```
git checkout production-v4
```

### Run the update script 
```
scripts/update_turnkey.sh
```
The update_turnkey.sh script will provide output that informs you of the update process. As part of this process, the update process will check to see if your repoistory has data in it that needs to be updated to match the new AIRR v1.4 specificiation. If it does, it will refer you to this page, and ask you to follow the directions below. This output will appear as follows:
```
Checking if the database needs to be updated..
Warning: the version 1.3 of the AIRR standards requires a database update. 
Please go to https://github.com/sfu-ireceptor/turnkey-service-php/blob/production-v4/doc/upgrading_from_v3_to_v4.md for more information
```

## Upgrading the data in your iReceptor Turnkey repository

As of September 2022 the AIRR Community released the [AIRR v1.4 specification](https://www.antibodysociety.org/airr-community/airr-community-standards-v1-4-now-available/), details of which can be found in the [v1.4 Release Notes page](https://docs.airr-community.org/en/stable/news.html). iReceptor v4.0 supports the AIRR v1.4 data specification and AIRR Data Commons v1.2 query API and in order to be compliant with this new specification, some data updates in your repository are necessary. These updates are primarily around being more precise in the specification, with the key changes converting `string` fields to combined `numerical` and unit `ontology` fields. 

The main fields impacted by these changes are:
- `keywords_study`: this field is a controlled vocabulary. Some of the vocabulary terms have changed and new terms have been added.
- `collection_time_point_relative`: this field was orginally a string that had a time point that was relative to a `collection_time_point_event`. For example you might have a `collection_time_point_event` of "Symptom Onset" and a `collection_time_point_relative` for a sample that was taken on "Day 4". This of course makes it very difficult to compare time courses, since the numerical value and units are combined in a single string. The AIRR Standard has changed this field to be a numerical value "4" and a label and ID from the [Unit Ontology (UO)](https://www.ebi.ac.uk/ols/search?q=year&ontology=uo) in the form of `collection_time_point_relative_unit.id:"UO:0000036"` and `collection_time_point_relative_unit.label;"year"`
- `template_amount`: this field used to be a string that provided a measurement for the amount of template material used in a sample. As above, strings are ill-suited for storing measurements, and this field has  been split into two fields, a numeric `template_amount` (e.g. `template_amount:10`) and a unit ontology label and ID (e.g. `template_amount_unit.id: UO:0000024`, `template_amount_unit.label: "nanogram"`).
- Dates: Although date fields were formally not AIRR fields, the AIRR specification has added time and date fields for noting when records were created and updated. The iReceptor Turnkey has always maintained such records, but these internal records need to be converted to ISO standard dates. 

We have provided scripts that will attempt to automatically update the data in your repository. Details on these scripts are provided below.

:warning: The following commands will update the database. Before making changes to the repository, you should consider making 
a [backup of the database](database_backup.md).
