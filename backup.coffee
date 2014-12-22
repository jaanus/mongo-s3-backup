exec = require('child_process').exec
S = require 'string'
AWS = require "aws-sdk"
fs = require 'fs'

env = process.env.NODE_ENV ? 'development'
config = require("./config")[env]

AWS.config.update(
  region: config.aws_region
  accessKeyId: config.aws_access_key_id
  secretAccessKey: config.aws_secret_access_key
)

exec "mongodump -d " + config.db_name, (error, stdout, stderr) ->
  if error
    console.log "Error creating the dump: ", error
    return

  dateString = new Date().toISOString()
  archiveName = config.db_name + "-" + dateString + ".bz2"
  archiveName = S(archiveName).replaceAll(":", "-").s


  exec "tar cjvf " + archiveName + " dump", (dump_error, dump_stdout, dump_stderr) ->
    if dump_error
      console.log "Error compressing the dump: ", dump_error
      return

    console.log "archive name is", archiveName
    readStream = fs.createReadStream(archiveName)

    console.log "arhcive name", archiveName
    prefixed_archiveName = archiveName
    if config.aws_bucket_path
      prefixed_archiveName = config.aws_bucket_path + archiveName
    console.log "uploading to", prefixed_archiveName

    params =
      Key: prefixed_archiveName
      Body: readStream

    s3bucket = new AWS.S3({params: { Bucket: config.aws_bucket }})

    s3bucket.upload params, (err, data) ->
      if err
        console.log "upload error", err
      else
        console.log "uploaded data."


    exec "rm " + archiveName, (rm_error, rm_stdout, rm_stderr) ->
      exec "rm -rf dump", (rm2_error, rm2_stdout, rm2_stderr) ->
        console.log "Done."
