#!/bin/sh
WORKSPACE=$1
echo "Removing old meta data to ensure clean new p2 site"
rm -Rf $WORKSPACE/.metadata
rm -Rf $WORKSPACE/features
rm -Rf $WORKSPACE/plugins
rm -Rf $WORKSPACE/output
rm -Rf $WORKSPACE/temp
echo "Preparation completed"
echo "Linking project git repository"
ln -sfT /var/lib/jenkins/jobs/MOST-0_Fetch-1_Product/workspace/scm "$WORKSPACE/refProduct"