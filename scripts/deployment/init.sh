#!/bin/sh

export PROJECT_ID=$(gcloud projects list --filter='name:"Thesis-Project"' --format="value(PROJECT_ID)")
export PROJECT_NUMBER=$(gcloud projects list --filter='name:"Thesis-Project"' --format="value(PROJECT_NUMBER)")
gcloud container clusters create-auto thesis-project --region=us-west1 # --labels="mesh_id=proj-$PROJECT_NUMBER"

# enable Anthos Service Mesh on your project's Fleet
gcloud container fleet mesh enable

# register the GKE cluster to the fleet
gcloud container fleet memberships register thesis-project-membership --gke-cluster=us-west1/thesis-project --enable-workload-identity

# add mesh_id label to gke cluster (do not do if already done while creating the cluster)
gcloud container clusters update  --project $PROJECT_ID thesis-project --region us-west1 --update-labels mesh_id=proj-$PROJECT_NUMBER

# enable automatic management
gcloud container fleet mesh update --management automatic --memberships thesis-project-membership

# verify that managed Anthos Service Mesh has been enabled for the cluster and is ready to be used
# gcloud container fleet mesh describe

# apply the default injection labels to the namespace
kubectl label namespace default istio-injection=enabled istio.io/rev- --overwrite # try what happens with 'istio.io/rev=asm-managed-regular'
# I don't get if I need to do this as well (should be to label the dataplane in case it's managed): kubectl annotate --overwrite namespace YOUR_NAMESPACE mesh.cloud.google.com/proxy='{"managed":"true"}
