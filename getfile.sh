#!/bin/bash

set -e

URI=$@ # eg: gitlab://username/project:master/kubernetes/helm-chart
PROVIDER=$(echo $URI | cut -d: -f1) # eg: gitlab, bitbucket
REPO=$(echo $URI | cut -d: -f2 | sed -e "s/\/\///") # eg: username/project
BRANCH=$(echo $URI | cut -d: -f3 | cut -d/ -f1) # eg: master
FILEPATH=$(echo $URI | cut -d: -f3 | sed -e "s/$BRANCH\///") # eg: kubernetes/helm-chart

# echo $URI $REPO $BRANCH $FILEPATH >&2

# make a temporary dir
TMPDIR="$(mktemp -d)"
cd $TMPDIR

git init --quiet
if [ "bitbucket" = $PROVIDER ]; then
#  git remote add origin git@bitbucket.org:$REPO.git
#elif [ "bitbucket-https" = $PROVIDER ]; then
  git remote add origin https://bitbucket.org/$REPO.git
else
  git remote add origin git@$PROVIDER.com:$REPO.git
fi
git pull --depth=1 --quiet origin $BRANCH

if [ -f $FILEPATH ]; then # if a file named $FILEPATH exists
  cat $FILEPATH
else
  echo "Root path" >&2
  cat $FILEPATH
  #echo "Error in plugin 'helm-git': $BRANCH:$FILEPATH does not exists" >&2
  #exit 1
fi

# remove the temporary dir
rm -rf $TMPDIR
