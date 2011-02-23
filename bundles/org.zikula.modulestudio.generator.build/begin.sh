echo "Linking project git repository"
ln -sf /var/lib/jenkins/jobs/MOST-0_Fetch-1_Product/workspace/scm/ $WORKSPACE/refProduct
echo "Removing old meta data to ensure clean new p2 site"
rm -Rf $WORKSPACE/.metadata
rm -Rf $WORKSPACE/features
rm -Rf $WORKSPACE/plugins
rm -Rf $WORKSPACE/output
rm -Rf $WORKSPACE/temp
echo "Preparation completed"
