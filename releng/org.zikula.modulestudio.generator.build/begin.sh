#!/bin/sh
WORKSPACE=$1
GIT_REVISION=$2

echo "Writing current git revision into file"
echo $GIT_REVISION > $WORKSPACE/scm/bundles/org.zikula.modulestudio.generator/src/gitrevision.txt
