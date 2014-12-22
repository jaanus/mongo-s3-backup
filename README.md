# mongo-s3-backup

This is a very simple Node script that does two things:

* Dumps a MongoDB database with `mongodump`.
* Compresses and uploads the result into S3 as a timestamped backup.

As discussed in [MongoDB docs](http://docs.mongodb.org/manual/core/backups/#backup-with-mongodump), dumping with `mongodump` may have a performance impact. In higher-traffic services, you may not want to use this.

## Setup

* Copy [`config.example.coffee`](config.example.coffee) to `config.coffee`.
* Edit the config.
* You can now run the script.

tbd … installing in cron.
