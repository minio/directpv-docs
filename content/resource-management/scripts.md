---
title: Scripts
date: 2023-07-07
lastmod: :git
draft: false
tableOfContents: true
weight: 1000
---

## replace.sh

Use the below script to replace a drive.
See [replacing a drive]({{< relref "/resource-management/drives.md#replace-drive" >}}) for more information on how to use this script.

```sh {.copy}
#!/usr/bin/env bash
#
# This file is part of MinIO DirectPV
# Copyright (c) 2023 MinIO, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#
# This script replaces source drive to destination drive in the specified node
#

set -e

# usage: get_drive_id <node> <drive-name>
function get_drive_id() {
    kubectl get directpvdrives \
            --selector="directpv.min.io/node==${1},directpv.min.io/drive-name==${2}" \
            -o go-template='{{range .items}}{{.metadata.name}}{{end}}'
}

# usage: get_volumes <drive-id>
function get_volumes() {
    kubectl get directpvvolumes \
            --selector="directpv.min.io/drive=${1}" \
            -o go-template='{{range .items}}{{.metadata.name}}{{ " " | print }}{{end}}'
}

# usage: get_pod_name <volume>
function get_pod_name() {
    # shellcheck disable=SC2016
    kubectl get directpvvolumes "${1}" \
            -o go-template='{{range $k,$v := .metadata.labels}}{{if eq $k "directpv.min.io/pod.name"}}{{$v}}{{end}}{{end}}'
}

# usage: get_pod_namespace <volume>
function get_pod_namespace() {
    # shellcheck disable=SC2016
    kubectl get directpvvolumes "${1}" \
            -o go-template='{{range $k,$v := .metadata.labels}}{{if eq $k "directpv.min.io/pod.namespace"}}{{$v}}{{end}}{{end}}'
}

function init() {
    if [[ $# -eq 4 ]]; then
        echo "usage: replace.sh <NODE> <SRC-DRIVE> <DEST-DRIVE>"
        echo
        echo "This script replaces source drive to destination drive in the specified node"
        exit 255
    fi

    if ! which kubectl >/dev/null 2>&1; then
        echo "kubectl not found; please install"
        exit 255
    fi

    if ! kubectl directpv --version >/dev/null 2>&1; then
        echo "kubectl directpv not found; please install"
        exit 255
    fi
}

function main() {
    node="$1"
    src_drive="${2#/dev/}"
    dest_drive="${3#/dev/}"

    # Get source drive ID
    src_drive_id=$(get_drive_id "${node}" "${src_drive}")
    if [ -z "${src_drive_id}" ]; then
        echo "source drive ${src_drive} on node ${node} not found"
        exit 1
    fi

    # Get destination drive ID
    dest_drive_id=$(get_drive_id "${node}" "${dest_drive}")
    if [ -z "${dest_drive_id}" ]; then
        echo "destination drive ${dest_drive} on node ${node} not found"
        exit 1
    fi

    # Cordon source and destination drives
    if ! kubectl directpv cordon "${src_drive_id}" "${dest_drive_id}"; then
        echo "unable to cordon drives"
        exit 1
    fi

    # Cordon kubernetes node
    if ! kubectl cordon "${node}"; then
        echo "unable to cordon node ${node}"
        exit 1
    fi

    mapfile -t volumes < <(get_volumes "${src_drive_id}")
    IFS=' ' read -r -a volumes_arr <<< "${volumes[@]}"
    for volume in "${volumes_arr[@]}"; do
        pod_name=$(get_pod_name "${volume}")
        pod_namespace=$(get_pod_namespace "${volume}")

        if ! kubectl delete pod "${pod_name}" --namespace "${pod_namespace}"; then
            echo "unable to delete pod ${pod_name} using volume ${volume}"
            exit 1
        fi
    done

    if [ "${#volumes_arr[@]}" -gt 0 ]; then
        # Wait for associated DirectPV volumes to be unbound
        while kubectl directpv list volumes --no-headers "${volumes_arr[@]}" | grep -q Bounded; do
            echo "...waiting for volumes to be unbound"
            sleep 10
        done
    else
        echo "no volumes found in source drive ${src_drive} on node ${node}"
    fi

    # Run move command
    kubectl directpv move "${src_drive_id}" "${dest_drive_id}"

    # Uncordon destination drive
    kubectl directpv uncordon "${dest_drive_id}"

    # Uncordon kubernetes node
    kubectl uncordon "${node}"
}

init "$@"
main "$@"
```

## push-images.sh

Use this script to push all required images to a private registry.

`push-images.sh example.org/myuser`


```sh {.copy}
#!/usr/bin/env bash
#
# This file is part of MinIO DirectPV
# Copyright (c) 2023 MinIO, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#
# This script pushes DirectPV and its sidecar images to private registry.
#

set -o errexit
set -o nounset
set -o pipefail

declare registry podman

function init() {
    if [ "$#" -ne 1 ]; then
        cat <<EOF
USAGE:
  push-images.sh <REGISTRY>
ARGUMENT:
<REGISTRY>    Image registry without 'http' prefix.
EXAMPLE:
$ push-images.sh example.org/myuser
EOF
        exit 255
    fi
    registry="$1"

    if which podman >/dev/null 2>&1; then
        podman=podman
    elif which docker >/dev/null 2>&1; then
        podman=docker
    else
        echo "no podman or docker found; please install"
        exit 255
    fi
}

# usage: push_image <image>
function push_image() {
    image="$1"
    private_image="${image/quay.io\/minio/$registry}"
    echo "Pushing image ${image}"
    "${podman}" pull --quiet "${image}"
    "${podman}" tag "${image}" "${private_image}"
    "${podman}" push --quiet "${private_image}"
}

function main() {
    push_image "quay.io/minio/csi-node-driver-registrar:v2.6.3"
    push_image "quay.io/minio/csi-provisioner:v3.4.0"
    push_image "quay.io/minio/csi-provisioner:v2.2.0-go1.18"
    push_image "quay.io/minio/livenessprobe:v2.9.0"
    push_image "quay.io/minio/csi-resizer:v1.7.0"
    release=$(curl -sfL "https://api.github.com/repos/minio/directpv/releases/latest" | awk '/tag_name/ { print substr($2, 3, length($2)-4) }')
    push_image "quay.io/minio/directpv:v${release}"
}

init "$@"
main "$@"
```

## remove-node.sh

Use this script to remove an empty node no longer needed for DirectPV.

```sh {.copy}
#!/usr/bin/env bash
#
# This file is part of MinIO DirectPV
# Copyright (c) 2023 MinIO, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -e -C -o pipefail

declare NODE

function delete_resource() {
    resource="$1"
    selector="directpv.min.io/node=${NODE}"

    # unset the finalizers
    kubectl get "${resource}" --selector="${selector}" -o custom-columns=NAME:.metadata.name --no-headers | while read -r name; do
        kubectl patch "${resource}" "${name}" -p '{"metadata":{"finalizers":null}}' --type=merge
    done

    # delete the objects
    kubectl delete "${resource}" --selector="${selector}" --ignore-not-found=true
}

function init() {
    if [[ $# -ne 1 ]]; then
        cat <<EOF
usage: remove-node.sh <NODE>
This script forcefully removes all the DirectPV resources from the node.
CAUTION: Remove operation is irreversible and may incur data loss if not used cautiously.
EOF
        exit 255
    fi

    if ! which kubectl >/dev/null 2>&1; then
        echo "kubectl not found; please install"
        exit 255
    fi

    NODE="$1"

    if kubectl get --ignore-not-found=true csinode "${NODE}" -o go-template='{{range .spec.drivers}}{{if eq .name "directpv-min-io"}}{{.name}}{{break}}{{end}}{{end}}' | grep -q .; then
        echo "node ${NODE} is still in use; remove node ${NODE} from DirectPV DaemonSet and try again"
        exit 255
    fi
}

function main() {
    delete_resource directpvvolumes
    delete_resource directpvdrives
    delete_resource directpvinitrequests
    kubectl delete directpvnode "${NODE}" --ignore-not-found=true
}

init "$@"
main "$@"
```

## create-storage-class.sh

Use the following script to create a new DirectPV storage class.

To use the script, use the following format:

```sh
create-storage-class.sh [new-storage-class-name] '[drive label]'
```

```sh {.copy}
#!/usr/bin/env bash
#
# This file is part of MinIO DirectPV
# Copyright (c) 2023 MinIO, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -e -C -o pipefail

declare NAME
declare -a DRIVE_LABELS

function init() {
    if [[ $# -lt 2 ]]; then
        cat <<EOF
USAGE:
  create-storage-class.sh <NAME> <DRIVE-LABELS> ...

ARGUMENTS:
  NAME           new storage class name.
  DRIVE-LABELS   drive labels to be attached.

EXAMPLE:
  # Create new storage class 'fast-tier-storage' with drive labels 'directpv.min.io/tier: fast'
  $ create-storage-class.sh fast-tier-storage 'directpv.min.io/tier: fast'

  # Create new storage class with more than one drive label
  $ create-storage-class.sh fast-tier-unique 'directpv.min.io/tier: fast' 'directpv.min.io/volume-claim-id: bcea279a-df70-4d23-be41-9490f9933004'
EOF
        exit 255
    fi

    NAME="$1"
    shift
    DRIVE_LABELS=( "$@" )

    for val in "${DRIVE_LABELS[@]}"; do
        if ! [[ "${val}" =~ ^directpv.min.io/.* ]]; then
            echo "invalid label ${val}; label must start with 'directpv.min.io/'"
            exit 255
        fi
        if [[ "${val}" =~ ^directpv.min.io/volume-claim-id:.* ]] && ! [[ "${val#directpv.min.io/volume-claim-id: }" =~ ^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$ ]]; then
            echo "invalid volume-claim-id value; the value must be UUID as textual representation mentioned in https://en.wikipedia.org/wiki/Universally_unique_identifier#Textual_representation"
            exit 255
        fi
    done

    if ! which kubectl >/dev/null 2>&1; then
        echo "kubectl not found; please install"
        exit 255
    fi
}

function main() {
    kubectl apply -f - <<EOF
allowVolumeExpansion: true
allowedTopologies:
- matchLabelExpressions:
  - key: directpv.min.io/identity
    values:
    - directpv-min-io
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  finalizers:
  - foregroundDeletion
  labels:
    application-name: directpv.min.io
    application-type: CSIDriver
    directpv.min.io/created-by: kubectl-directpv
    directpv.min.io/version: v1beta1
  name: ${NAME}
parameters:
  fstype: xfs
$(printf '  %s\n' "${DRIVE_LABELS[@]}")
provisioner: directpv-min-io
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF
}

init "$@"
main "$@"
```
