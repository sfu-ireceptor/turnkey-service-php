# Resetting the turnkey

:warning: This will erase the turnkey database.

```
# stop turnkey
scripts/stop_turnkey.sh 

# delete database folder contents
sudo rm -Rf .mongodb_data/*

# start turnkey
scripts/start_turnkey.sh
```
