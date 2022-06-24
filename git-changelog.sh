#!/bin/bash

echo "# Changelog"
echo

declare -r USER=JohnDevlopment
declare -r PROJECT=factory-level

git log ${1:?provide revision range} \
    --pretty=format:"* [view commit &bull;](https://github.com/$USER/$PROJECT/commit/%H) %s " \
    --reverse
