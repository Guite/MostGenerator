echo "Starting client build job."

echo "Linking product git repository"
ln -sfT /var/lib/jenkins/jobs/MOST-0_Fetch-1_Product/workspace/scm "$WORKSPACE/refProduct"

echo "Linking applications git repository"
ln -sfT /var/lib/jenkins/jobs/Applications/workspace/scm "$WORKSPACE/refApplications"
echo "Creating working directory."
mkdir -p tempWorkingDir

echo "Creating gen-output directory."
mkdir -p output
mkdir -p output/zclassic
mkdir -p output/reporting
