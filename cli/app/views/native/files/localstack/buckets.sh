#!/usr/bin/env bash

set -eEuo pipefail

buckets=(
  # v*
  perx-cdn-development images
)

for b in ${buckets[@]}; do
  awslocal s3 mb s3://$b
done
