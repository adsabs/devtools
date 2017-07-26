#!/bin/bash -e

# This script will execute application that was uploaded to S3

bucket=${EBS_BUCKET:-elasticbeanstalk-us-east-1-084981688622}
target=`basename $1`
bucketname=$target
version=$2
extra=$3

if [[ "$target" = "" || "$target" = "help" ]]; then
  echo "
  Script to locally run the applications from S3

  Usage: $0 <appname> [version]

  Example:

    `basename $0` backoffice

    Will donwload the last app uploaded to backoffice and execute it.

    `basename $0` backoffice adsorcid

    Will download the latest version of adsorcid and execute it. The second
    argument serves as a filter. So you can pass any string.

    You should always run this script as 'ads' (UID=102) user. Or add '--force'
    parameter.
  "
  exit 0
fi

if [[ "$UID" != "102" ]]; then
  if [[ "$extra" = "--force" ]]; then
    echo "Not running as user 'ads' (UID=102); I hope you know what you are doing!"
  else
    echo "This script needs to run as 'ads' user (sudo su -l ads) or with --force as 3rd argument"
    exit 1
  fi
fi


olddir=`pwd`

s3_file=""
if [[ "$version" = "" ]]; then
  while read x; do
    f=$(echo $x| tr -s ' ' | cut -d ' ' -f 4)
    if [[ "$f" != "" ]]; then
      s3_file="$f"
      foos=$f
    fi
  done < <(aws s3 ls s3://$bucket/$target/ | sort)
else
  while read x; do
    f=$(echo $x| tr -s ' ' | cut -d ' ' -f 4)
    if [[ "$f" != "" ]]; then
      s3_file="$f"
    fi
  done < <(aws s3 ls s3://$bucket/$target/ | grep $version | sort)
fi

echo "Going to run: $s3_file"

if [[ "$s3_file" = "" ]]; then
  echo "Could not find anything in S3 bucket; exiting"
  exit 1
fi

appname=$(echo "$s3_file" | cut -d ':' -f 1)
if [[ "$appname" != "" ]]; then
  target="$target"_"$appname"
fi


if [[ `docker ps | grep "$target" | wc -l` -gt 1 ]]; then
  read -p "Shall I stop the existing docker container (before replacing it)?: $target [n]" answer
  if [[ "${answer:-n}" == "y" ]]; then
    docker stop "$target"
  else
    docker ps | grep "$target"
    echo "Left running"
  fi
fi


if [[ ! -e $target ]]; then
  echo "Creating folder $olddir/$target"
  mkdir -p "$olddir/$target"
else
  echo "We detected that the installation folder $olddir/$target already exists."
  read -p "Shall we overwrite existing contents? $olddir/$target [n]" answer

  if [[ "${answer:-n}" == "y" ]]; then
    : # do nothing
  else
    read -p "Do you want me to remove/replace it? $olddir/$target [n]" answer
    if [[ "${answer:-n}" == "y" ]]; then
      rm -fr "$olddir/$target"
      mkdir -p "$olddir/$target"
    else
      echo "Exiting"
      exit 0
    fi
  fi
fi

# copy the s3 file
aws s3 cp "s3://$bucket/$bucketname/$s3_file" "./$target/"

pushd $target
unzip -o $s3_file


# stop the docker (if running)
docker rm -f $target || true

# build
docker build -t $target .
imageid=`docker images -q $target`

if [ "$?" = "0" ]; then
    if [ -e "$olddir/$target/docker-run.sh" ]; then

      if [[ ! -e run-manualy.sh ]]; then
        echo "#!/bin/bash
        docker rm $target
        $olddir/$target/docker-run.sh  $target $imageid" > run-manually.sh && chmod u+x run-manually.sh
      fi

      echo "Executing $olddir/$target/docker-run.sh"
      $olddir/$target/docker-run.sh  $target $imageid
    else

      if [[ ! -e run-manualy.sh ]]; then
        echo "#!/bin/bash
        docker rm $target
        docker run -d -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/:/var/lib/docker -v /media/shared_folder:/media/shared_folder --name $target $imageid" > run-manually.sh | chmod u+x run-manually.sh
      fi

      echo "Executing the default docker run sequence"
      docker run -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/:/var/lib/docker -v /media/shared_folder:/media/shared_folder --name $target $imageid
    fi
else
  echo "Failed to build the docker image; exiting"
  exit 1
fi
popd
