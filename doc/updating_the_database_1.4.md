# Upgrading your repository data for the AIRR v1.4 specification

As of September 2022 the AIRR Community released the [AIRR v1.4 specification](https://www.antibodysociety.org/airr-community/airr-community-standards-v1-4-now-available/) (see the [release notes](https://docs.airr-community.org/en/stable/news.html)). iReceptor v4.0 supports this new specification, but some data updates in your repository are required. These updates are about making the data more precise, the key change being the conversion of `string` fields to combined `numerical` + unit `ontology` fields. We have provided scripts that will attempt to automatically update the data in your repository.

# What will change

The main fields impacted by these changes are:
- `keywords_study`: this field is a controlled vocabulary. Some vocabulary terms have changed and new terms have been added.
- `collection_time_point_relative`: this field was orginally a string that had a time point that was relative to a `collection_time_point_event`. For example you might have a `collection_time_point_event` of "Symptom Onset" and a `collection_time_point_relative` for a sample that was taken on "Day 4". This makes it very difficult to compare time courses, since the numerical value and units are combined in a single string. The 1.4 specification has changed this field to be a numerical value "4" and a label and ID from the [Unit Ontology (UO)](https://www.ebi.ac.uk/ols/search?q=year&ontology=uo) in the form of `collection_time_point_relative_unit.id:"UO:0000036"` and `collection_time_point_relative_unit.label;"year"`
- `template_amount`: this field used to be a string that provided a measurement for the amount of template material used in a sample. As above, strings are ill-suited for storing measurements, and this field has  been split into two fields, a numeric `template_amount` (e.g. `template_amount:10`) and a unit ontology label and ID (e.g. `template_amount_unit.id: UO:0000024`, `template_amount_unit.label: "nanogram"`).
- Dates: Although date fields were formally not AIRR fields, the AIRR specification has added time and date fields for noting when records were created and updated. The iReceptor Turnkey has always maintained such records, but these internal records now need to be converted to ISO standard dates. 

# Updating the data

:warning: Your repository data will change. Before running the scripts below, we recommend making 
a [backup of the database](database_backup.md).

Run these scripts:

```
scripts/update_adc_date_fields.sh update
scripts/update_collection_time_point_relative.sh collection_time_point_relative
scripts/update_dates.sh sample '%a %b %d %Y %H:%M:%S %Z'
scripts/update_keywords_study.sh keywords_study single_cell ir_sequence_count
scripts/update_template_amount.sh template_amount
```

# Checking it worked

Make sure no more update is required by running `scripts/update_turnkey.sh` and checking the warning message does not appear anymore.

# What to do if something went wrong

Each of the update scripts above will report if it could not change a field. There are several reasons this might happen:

- You have previously run the script on your repository and fields have already been updated. For example, if you have already run `update_adc_update.sh` the correct date will be already in the repository, and the conversion will not recognize the date field because it is not in the old format.
- A field can not be converted. For both `update_collection_time_point_relative.sh` and `update_template_amount.sh` the conversion attempts to change fields like `4 years` to an integer field `4` and an ontology time field represented by `year, UO:0000036`. If the conversion cannot deduce either the value or the unit, the script will inform you and tell for which repertoire record the problem ocurred. In each case, the original data in the repository will be stored in a field with the same name with an `ir_` as a name prefix. This ensures that know data is lost.

In each case where an error is reported, the data curator should assess what the problem is and determine how to fix the problem. For example, if the field contains a typo of word "day" in the field (`4 dys`), this will not be converted because "dys" is not a recognized time unit. In this case the curator should fix this problem using the [update metadata](../turnkey-service-php#updating-repertoire-metadata) process on a repertoire by repertoire basis. 
