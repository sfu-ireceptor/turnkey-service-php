# Customizing the /airr/v1/info entry point

How to customize the contact information returned by https://localhost/airr/v1/info.

## Create .env from .env-custom
```
cp scripts/.env-custom scripts/.env
```

## Customize .env
The default values are:
```
AIRR_INFO_CONTACT_NAME=Test Repository
AIRR_INFO_CONTACT_URL=https://test-repository.com
AIRR_INFO_CONTACT_EMAIL=support@test-repository.com
```

## Restart the turnkey
```
scripts/stop_turnkey.sh
scripts/start_turnkey.sh 
```

## Check it worked
```
curl -k https://localhost/airr/v1/info
```

## How it works

The scripts/.env file overrides the values defined in scripts/docker-compose.yml.


## Switching back to the default values

Just delete the .env file and restart the turnkey:
```
rm scripts/.env
scripts/stop_turnkey.sh
scripts/start_turnkey.sh 
```
