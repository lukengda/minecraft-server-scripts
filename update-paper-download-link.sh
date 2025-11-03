#!/bin/bash

data=$(curl -s https://qing762.is-a.dev/api/papermc/latest)

minecraft_version=$(jq -r '.latest' <<<"$data")
url=$(jq -r '.url' <<<"$data")
filename=$(basename "$url")

echo "Latest papermc download version: $filename"
echo "Updating jargroup papermc…"
sudo msm jargroup changeurl papermc "$url"
#sudo msm jargroup getlatest papermc
echo
echo "Please run 'sudo msm stable jar papermc' and 'sudo msm stable restart' now to apply the new version to server _stable_."
