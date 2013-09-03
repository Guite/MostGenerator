#!/bin/sh
WORKSPACE=$1
GIT_REVISON=$2
echo "Linking project git repository"
ln -sfT /var/lib/jenkins/jobs/MOST-0_Fetch-1_Product/workspace/scm "$WORKSPACE/refProduct"

mkdir -p $WORKSPACE/output/test_results/coverage/

echo "writing git revision to file"
echo $GIT_REVISION > $WORKSPACE/scm/org.zikula.modulestudio.generator/src/gitrevision.txt