# Add a section for each environment that you wish to use this script in.

module.exports =

  development:

    # Mongo database name
    db_name: "dev_database"

    # AWS setup
    aws_region: "eu-west-1"
    aws_access_key_id: "your-access-key"
    aws_secret_access_key: "your-secret"
    aws_bucket: "your-bucket"

    # Optional path in the bucket. May be omitted to upload to the root of the bucket.
    aws_bucket_path: "your-folder"
