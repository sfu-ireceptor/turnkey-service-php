# Using an external volume

Because the Mongo database can be quite large, it is often necessary to use a directory on an external volume rather
than the roor volumen of your server/VM.

Although any file system can be used, [Mongo recommends using the XFS file system](https://docs.mongodb.com/manual/administration/production-checklist-operations/),
so if possible use such a volume for the MongoDB directory.

Configuring and mounting such a volume is outside the scope of this document, please refer to your OS documentation for more information.
The remainder of this document assumes that you have an XFS file system configured and mounted on /data in your local filesystem. Note that these
steps should also be taken *before* you have loaded any data into your Turnkey repository.

The following commands assume you are working from the installation directory, typically ~/turnkey-service-php if installed as a user.

1. Create a mongodb directory

We want to create a new MongoDB data directory on our large, XFS volume.
```
sudo mkdir /data/mongodb
```

1. Stop the turnkey

Whenever you are working with database files directly, the Turnkey should be stopped.
```
scripts/stop_turnkey.sh
```

2. Move the current mongodb data folder

The Turnkey uses the .mongodb_data directory as the data directory for MongoDB. We don't want to
destroy this directory, so we just move it.
```
sudo mv .mongodb_data mongodb_data_original
```

2. Create a symbolic link to the new location
```
ln -s /data/mongodb .mongodb_data
```

3. Start the turnkey
```
scripts/start_turnkey.sh
```

4. Check that the data is being written to the new location

```
ls /data/mongodb
```
Once the Turnkey has been started, MongoDB will create a set of Mongo files for your new Mongo repository. Congratulations,
you now have a empty Mongo repository storing data on your new XFS file system. Feel free to load your data.
