#!/bin/sh

TODAY=`date +%d-%m-%Y:%H-%M-%S`

BRANCH=""

if [ -z "$1" ]; then
    BRANCH="main"
else
    BRANCH="$1"
fi

git add .
git commit -m "Update Code at: ${TODAY}"
git push origin $BRANCH

exit 0