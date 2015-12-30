exec = require('child_process').exec
S = require 'string'
AWS = require "aws-sdk"
fs = require 'fs'
async = require 'async'
mkpath = require 'mkpath'

env = process.env.NODE_ENV ? 'development'
config = require("./config")[env]

archiveName = null

backup_to_aws = (callback) ->

  if !config.backup_to_aws
    callback null
    return

  AWS.config.update(
    region: config.aws_region
    accessKeyId: config.aws_access_key_id
    secretAccessKey: config.aws_secret_access_key
  )

  readStream = fs.createReadStream(archiveName)
  prefixed_archiveName = archiveName
  if config.aws_bucket_path
    prefixed_archiveName = config.aws_bucket_path + archiveName

  params =
    Key: prefixed_archiveName
    Body: readStream

  s3bucket = new AWS.S3({params: { Bucket: config.aws_bucket }})

  s3bucket.upload params, (upload_err, data) ->
    if upload_err
      console.log "Error uploading to S3:", upload_err
      callback upload_err
    else
      callback null

backup_to_local_path = (callback) ->
  if !config.backup_to_local_path
    callback null
    return

  mkpath config.local_path, (err) ->
    if err
      callback err
    else
      exec "cp " + archiveName + " " + config.local_path, (cp_error, cp_stdout, cp_stderr) ->
        if cp_error
          callback cp_error
        else
          callback null

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

    async.series [ backup_to_aws, backup_to_local_path ], (err, results) ->
      if err
        console.log "Backup error. Not removing dump", err
      else
        exec "rm " + archiveName, (rm_error, rm_stdout, rm_stderr) ->
          exec "rm -rf dump", (rm2_error, rm2_stdout, rm2_stderr) ->
            return
