# Moving the database to another location

Because the MongoDB database can be quite large, it is often necessary to move it to an external volume rather
than using the root disk of your server/VM.

Although any file system can be used, [Mongo recommends using the XFS file system](https://docs.mongodb.com/manual/administration/production-checklist-operations/).

The database data is in the `.mongodb_data` folder. To move it somewhere else (for example to an external volume):

1. Stop the turnkey
```
scripts/stop_turnkey.sh
```

2. Rename and move the data folder
```
sudo mv .mongodb_data ireceptor_turnkey_mongodb_data
sudo mv ireceptor_turnkey_mongodb_data <another folder>
```

2. Create a symbolic link to the new location
```
ln -s <another folder>/ireceptor_turnkey_mongodb_data .mongodb_data
```

3. Start the turnkey
```
scripts/start_turnkey.sh
```
