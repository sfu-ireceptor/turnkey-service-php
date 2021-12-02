# Installing a custom SSL certificate

A self-signed SSL certificate is installed by default. This will generate a security warning in browsers. To use your own SSL certificate:

1. Replace the SSL certificate files in the `.ssl` folder by your own. Make sure to use the same names: 

```
certificate.pem
private-key.pem
intermediate.pem
```

2. Restart the turnkey

```
scripts/stop_turnkey.sh
scripts/start_turnkey.sh
```
