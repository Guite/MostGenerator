#!/bin/bash

# list projects
PROJECTS=(
    "Guite/test-actions"
    "Guite/Awards"
#    "zikula-modules/Content"
#    "zikula-modules/MultiHook"
#    "zikula-modules/Multisites"
#    "zikula-modules/News"
#    "zikula-modules/Pages"
#    "zikula-modules/Ratings"
)

# loop through projects
for PROJECT in "${PROJECTS[@]}"
do
    echo "Trigger ${PROJECT}"
    curl POST -H "Authorization: token ${DISPATCH_TOKEN}" \
              -H "Accept: application/vnd.github.everest-preview+json"  \
              -H "Content-Type: application/json" \
              "https://api.github.com/repos/${PROJECT}/dispatches" \
              --data '{"event_type": "generator-updated"}' \
              --silent
done
