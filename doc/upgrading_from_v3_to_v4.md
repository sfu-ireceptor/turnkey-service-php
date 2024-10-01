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

:warning: This update script will also check if your repository requires any data update to match the new AIRR v1.4 specificiation. If it does, it will refer you to  [Upgrading the data in your iReceptor Turnkey repository](updating_the_database_1.4.md).
