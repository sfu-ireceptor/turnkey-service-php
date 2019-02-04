# Backing up and restoring the database

## Backing up the database to a file

```
scripts/backup_database.sh > db.dump
```

## Restoring the database from a database backup

```
scripts/restore_database.sh < db.dump
```