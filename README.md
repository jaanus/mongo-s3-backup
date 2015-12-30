# mongo-s3-backup

This is a very simple Node script that does two things:

* Dumps a MongoDB database with `mongodump`, …
* … compresses and uploads the dump into S3 as a timestamped backup, and/or …
* … saves the dump in a local folder.

As discussed in [MongoDB docs](http://docs.mongodb.org/manual/core/backups/#backup-with-mongodump), dumping with `mongodump` may have a performance impact. In higher-traffic services, you may not want to use this.

## Setup

* Copy [`config.example.coffee`](config.example.coffee) to `config.coffee`.
* Edit the config.
* You can now run the script.

## Running in crontab

Here’s an example of how I run this in crontab every 6 hours.

    PATH = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
    SHELL = /bin/bash
    NODE_ENV = production
    0 0,6,12,18 * * * /path/to/coffee /path/to/backup.coffee >> /path/to/backup.log
