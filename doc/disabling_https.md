# Disabling HTTPS

If using a self-signed SSL certificate is a problem, it's possible to disable HTTPS, and use HTTP instead:
```
scripts/disable_https.sh
```

Check it's working:
```
curl --data "{}" "http://localhost/airr/v1/repertoire"
```

If needed, you can re-enable HTTPS later using:
```
scripts/enable_https.sh
```
