#!/bin/sh
WORKSPACE=$1
echo "Linking project git repository"
ln -sfT /var/lib/jenkins/jobs/MOST-0_Fetch-1_Product/workspace/scm "$WORKSPACE/refProduct"

mkdir -p $WORKSPACE/output/test_results/coverage/
