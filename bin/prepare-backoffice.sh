#!/bin/bash -e

# this script will set up environment for backoffice deployment
# usage: ./prepare-backoffice.sh

bin_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

echo "Installing some python/system packages"
sudo apt-get install python-pip python-virtualenv unzip


for target in `ls / | grep /proj.ads`; do
  echo "Currently looking into: $target"

  mkdir -p $target/backoffice
  cd $target/backoffice

  virtualenv python
  source python/bin/activate
  pip install -r $bin_dir/../eb-deploy-requirements.txt

  echo "$target is ready (if you saw no errors)"
  echo "you can do: cd $target && source python/bin/activate && run-s3-locally.sh backoffice <target>"

  deactivate
done
