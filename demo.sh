#!/bin/bash

# If model dir does not exist or is empty, download from bucket
if [ ! -d ./model ] || [ -z "$(ls -A ./model)" ]; then
  echo 'Enter results bucket name (e.g results-bucket)'
  read RESULTS_BUCKET
  RESULTS_BUCKET=$(echo $RESULTS_BUCKET|tr -d '\n')

  echo 'Enter training ID (e.g: training-1qw3sd4ds)'
  read TRAIN_ID

  echo 'Downloading saved model from specified bucket'
  aws --endpoint-url=http://s3-api.us-geo.objectstorage.softlayer.net s3 cp "s3://$RESULTS_BUCKET/$TRAIN_ID/" ./model --recursive

  # Replace old checkpoint paths with paths on local machine
  old_ckpt_path=$(head -n 1 model/checkpoint | awk {'print $NF'} | tr -d '"')
  ckpt_dir=$(dirname $old_ckpt_path)
  project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/model"
  sed -i .bak "s|$ckpt_dir|$project_dir|g" model/checkpoint
fi

python3 demo.py
