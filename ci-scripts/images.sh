#!/bin/bash
# CI test that builds images for both promote and gate jobs.
# For the promote jobs it publishes the image to the testing location.
# For the gate jobs it tests them with a full deploy.
# Usage: images.sh <release> <build_system> <config> <job_type>
set -eux

RELEASE=$1
BUILD_SYS=$2
CONFIG=$3
JOB_TYPE=$4

# These are set here to make it possible to locally reproduce the promote
# image building job in the same way as the other jobs.
PUBLISH=${PUBLISH:-"false"}
delorean_current_hash=${delorean_current_hash:-"consistent"}

if [ "$JOB_TYPE" = "gate" ] || [ "$JOB_TYPE" = "periodic" ]; then
    PLAYBOOK='build-images-and-quickstart.yml'
    delorean_current_hash='current-passed-ci'
elif [ "$JOB_TYPE" = "promote" ]; then
    PLAYBOOK='build-images.yml'
else
    echo "Job type must be one of gate, periodic, or promote"
    exit 1
fi

bash $WORKSPACE/tripleo-quickstart/quickstart.sh \
  --tags all \
  --config $WORKSPACE/config/general_config/$CONFIG.yml \
  --working-dir $WORKSPACE/ \
  --playbook $PLAYBOOK \
  --extra-vars undercloud_image_url="file:///var/lib/oooq-images/undercloud.qcow2" \
  --extra-vars artib_release=$RELEASE \
  --extra-vars artib_build_system=$BUILD_SYS \
  --extra-vars artib_delorean_hash=$delorean_current_hash \
  --extra-vars publish=$PUBLISH \
  --extra-vars artib_image_stage_location="${LOCATION:-'testing'}" \
  --no-clone \
  --release $RELEASE \
  $VIRTHOST
