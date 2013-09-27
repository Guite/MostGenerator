#!/bin/sh
WORKSPACE=$1
GIT_REVISION=$2
echo "Linking project git repository"
ln -sfT /var/lib/jenkins/jobs/MOST-0_Fetch-1_Product/workspace/scm "$WORKSPACE/refProduct"

echo "Cleaning xtend-gen folder"
rm -rf "$WORKSPACE/scm/org.zikula.modulestudio.generator/xtend-gen/*"

mkdir -p $WORKSPACE/output/test_results/coverage/

echo "Writing current git revision into file"
echo $GIT_REVISION > $WORKSPACE/scm/org.zikula.modulestudio.generator/src/gitrevision.txt
