#!/bin/bash



# --- CONFIGURATION ---

SOURCE_DIR="/var/log"

BUCKET_NAME="ujjawal-backup-676767"

DATE=$(date +%Y-%m-%d-%H-%M-%S)

BACKUP_FILE="logs-backup-$DATE.tar.gz"

AWS_CMD=$(which aws)



# 1. Compress the logs

echo "Creating backup of $SOURCE_DIR..."

tar -czf $BACKUP_FILE $SOURCE_DIR 2>/dev/null



# 2. Upload to S3

echo "Uploading to S3..."

$AWS_CMD s3 cp $BACKUP_FILE s3://$BUCKET_NAME/



# 3. Clean up local file

rm $BACKUP_FILE



echo "Backup completed successfully!"
