# Using the turnkey developement version

Warning: this is an unstable version, you might lose your data and encounter some serious bugs.

## Switching to the development version

```
scripts/stop_turnkey.sh
cp scripts/.env-dev .env
scripts/start_turnkey.sh 
```

## Switching back to the production version

```
scripts/stop_turnkey.sh
rm .env
scripts/start_turnkey.sh 
```
