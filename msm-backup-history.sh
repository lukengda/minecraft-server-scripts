#!/bin/bash
# Create long term backups of the world backups.
# This script is designed to grab the oldest backup
# and copies it to a separate location that is not
# automatically cleaned by msm cronjobs so that we
# can implement our own thin-out strategy.
#
# See /etc/cron.d/msm-backup-history for when this is called.
#
# ~lukengda

# Debugging:
#set -x

# Source directory
source_dir="/opt/msm/archives/worlds"

# Destination directory
destination_dir="/opt/msm/archives/worlds-ltbackup"

# Duration to keep different backups
keep_duration_weekly="62" # approx. four backups between 30 and 62 days old
keep_duration_monthly="365" # approx. ten backups between two and 12 months old
keep_duration_yearly="3650"

# Get the argument passed to the script
schedule="$1"
task="$2"

# Validate the arguments
if [ "$schedule" != "weekly" ] && [ "$schedule" != "monthly" ] && [ "$schedule" != "yearly" ]; then
    echo "Invalid argument. Please specify 'weekly', 'monthly' or 'yearly'."
    exit 1
fi
if [ "$task" != "cleanup" ] && [ "$task" != "create" ]; then
    echo "Invalid argument. Please specify command 'create' or 'cleanup'."
    echo "  msm-backup-history.sh weekly create"
    exit 1
fi

keep_duration="$keep_duration_weekly"
target_dir="$destination_dir/$schedule"

if [ "$schedule" == "monthly" ]; then
    source_dir="$destination_dir/weekly" # move files from "weekly" to "monthly"
    keep_duration="$keep_duration_monthly"
fi
if [ "$schedule" == "yearly" ]; then
    source_dir="$destination_dir/monthly" # move files from "monthly" to "yearly"
    keep_duration="$keep_duration_yearly"
fi


if [ "$task" == "cleanup" ]; then
    find $target_dir -mtime +$keep_duration -type f -name "*.zip" | xargs rm --force
    echo "Cleanup complete."
    exit 0
fi

# Find all folders containing zip files in the source directory recursively
folders_with_zips=$(find "$source_dir" -type f -name '*.zip' -exec dirname {} + | sort -u)


# Iterate over each folder
for folder_path in $folders_with_zips; do
    relative_path="${folder_path#$source_dir/}"  # Remove the source directory path to get the relative path

    # Find the oldest zip file in the folder
    oldest_zip=$(ls -1tr "$folder_path"/*.zip | head -n1)

        # Move the oldest zip file to the destination directory with the same path structure
    if [[ -n "$oldest_zip" ]]; then
        echo "Backing up $oldest_zip."
        mkdir -p "$target_dir/$relative_path"
        cp "$oldest_zip" "$target_dir/$relative_path/"
    fi
done

echo "Backup complete".
