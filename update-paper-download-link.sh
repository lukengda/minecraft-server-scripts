#!/bin/bash

# Define the API base URL
BASE_URL="https://api.papermc.io/v2"

# Fetch the list of projects
project=$(curl -s "$BASE_URL/projects" | jq -r '.projects[0]')

# Fetch the latest version of the selected project
version=$(curl -s "$BASE_URL/projects/$project" | jq -r '.versions[-1]')

# Fetch the latest build number for the latest version
build=$(curl -s "$BASE_URL/projects/$project/versions/$version/builds" | jq -r '.builds[-1].build')

# Get the download file name for the latest build
file=$(curl -s "$BASE_URL/projects/$project/versions/$version/builds/$build" | jq -r '.downloads.application.name')

# Construct the download URL
download_url="$BASE_URL/projects/$project/versions/$version/builds/$build/downloads/$file"

# update url in jargroup papermc:
echo "Latest papermc download URL: $download_url."
echo "Updating jargroup papermc, please run 'sudo msm jargroup getlatest papermc' to update."
sudo msm jargroup changeurl papermc "$download_url"
