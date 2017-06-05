#!/bin/bash -e

# purpose of this script is to automatically update the github
# repository


bin_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

cd $bin_dir/..
git pull > /dev/null

if [[ "$?" != "0" ]]; then
  echo "Problem updating repository at: " $(cd $bin_dir/.. && pwd)
fi
