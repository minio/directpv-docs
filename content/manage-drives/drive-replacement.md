---
title: Replace Drives
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

{{< admonition type="note" >}}
Drive replacement is available on version 3.2.2 or later.
{{< /admonition >}}

## Overview

This page describes the steps required to move volumes from one drive to another drive on the **same node**. 
This primarily occurs when replacing a drive on a node.

{{< admonition type="important" >}}
These steps move the volume references from the source drive to the destination drive.
This does not move the actual data.
{{< /admonition >}}


## Tutorial

Complete all of the parts of this tutorial in the sequence listed here.

If desired, a [bash script](#bash-script) can complete the steps after initializing the drive.

### Add the new drive to DirectPV

1. Physically install the new drive to the same node as the older drive you are replacing.

2. Tell DirectPV to Discover the new drive and generate the yaml file including the drive:

   ```sh {.copy}
   kubectl directpv discover --drives /dev/<drive-name>
   ```

   This command generates the `drives.yaml` file used for initialization. 
   
   See the [Discover CLI command]({{ relref "command-line/discover.md" }}) for more helpers on drive discovery.

3. Initialize the drive using the `drives.yaml` files

   Initializing the drive formats it and makes it available for DirectPV to use.
   
   ```sh {.copy}
   kubectl directpv init drives.yaml
   ```

4. Confirm DirectPV found and initialized the drive.
  
   Use the directpv list command to display the known drives and confirm the new drive appears in the list.
   
   ```sh {.copy}
   kubectl directpv list drives --drives /dev/<drive-name>
   ```

### Obtain Drive and Pod Information

1. Obtain the Drive IDs for the `Source` and `Destination` drives

   Retrieve the Drive IDs for the drive you are replacing (the "source" drive) and the new drive (the "destination" drive):

   ```sh {.copy}
   kubectl directpv list drives --drives <source-drive-name>,<dest-drive-name> --nodes <node-name> -o wide
   ```

2. Cordon off the `source` and `destination` drives

   Cordoning a drive marks the drives as unschedulable.
   This prevents DirectPV from scheduling any new volumes on these drives.

   Use the drive IDs you obtained in the previous step.
   
   ```sh {.copy}
   kubectl directpv cordon <source-drive-id> <dest-drive-id>
   ```

3. Identify the pods used by the source drive

   ```sh {.copy}
   kubectl directpv volumes list --all --drives /dev/<source-drive-name> --nodes <node-name>
   ```

### Prepare the Nodes and Pods

1. Cordon the corresponding kubernetes node and delete the pods used by the source drive

   This takes the workloads offline and prevents DirectPV from scheduling any new pods on this node.

   ```sh {.copy}
   kubectl cordon <node-name>
   ```

   {{< admonition type="warning" >}}
   Do not force delete pods.
   Force deletion may not unpublish the volumes.
   {{< /admonition >}}

   ```sh {.copy}
   kubectl delete pod/<pods-name> -n <pod-ns>
   ```

   The pod falls into `pending` status after deletion, as the node is cordoned.

2. Wait for associated DirectPV volumes to be unbounded

   There should be no volumes in `Bounded` state.

   ```sh {.copy}
   kubectl directpv volumes list --all --pod-names=<pod-name> --pod-namespaces=<pod-ns>
   ```

### Move to the new drive

1. Run the `move` command

   ```sh {.copy}
   kubectl directpv move <source-drive-id> <dest-drive-id>
   ```

2. List the drives to confirm the volumes moved to the destination drive. 

   ```sh {.copy}
   kubectl directpv list drives --drives <source-drive-name>,<dest-drive-name> --nodes <node-name> -o wide
   ```

3. Uncordon the destination drive

   This allows DirectPV to schedule the drive.

   ```sh {.copy}
   kubectl directpv uncordon <dest-drive-id>
   ```

4. Uncordon the Kubernetes node

   This allows DirectPV to schedule drives on a node.

   ```sh {.copy}
   kubectl uncordon <node-name>
   ```

Now, the corresponding workload pods should be coming up as the node is uncordoned. 
This pod will be using the new drive.

1. _(Optional)_ Remove the old drive from DirectPV

   This releases the drive as no longer used by DirectPV.
   
   ```sh {.copy}
   kubectl directpv remove <source-drive-id>
   ```

## Bash script for drive replacement

Alternatively, after installing the physical drive and initializing it with DirectPV, you can use a bash script to move the drives.

The following script performs all of the above steps aside from physically installing, detecting, and initializing the new drive to the node.
Pass the node name, source drive path, and destination device path to the command.

```sh
./replace.sh <node-name> /dev/<source-device-name> /dev/<destination-device-name>
```

### Example Script

Copy the below script and paste it into a text file.
Name the file `replace.sh` and place in a convenient directory.

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

ME=$(basename "$0"); export ME

export drive_id=""

# usage: get_drive_ids <node> <drive-name>
function get_drive_ids() {
    kubectl get directpvdrives \
            --selector="directpv.min.io/node==${1},directpv.min.io/drive-name==${2}" \
            -o go-template='{{range .items}}{{.metadata.name}} {{end}}'
}

# usage: get_volumes <drive-id>
function get_volumes() {
    kubectl get directpvvolumes \
            --selector="directpv.min.io/drive=${1}" \
            -o go-template='{{range .items}}{{.metadata.name}}{{ " " | print }}{{end}}'
}

# usage: get_pod_name <volume-id>
function get_pod_name() {
    # shellcheck disable=SC2016
    kubectl get directpvvolumes "${1}" \
            -o go-template='{{range $k,$v := .metadata.labels}}{{if eq $k "directpv.min.io/pod.name"}}{{$v}}{{end}}{{end}}'
}

# usage: get_pod_namespace <volume-id>
function get_pod_namespace() {
    # shellcheck disable=SC2016
    kubectl get directpvvolumes "${1}" \
            -o go-template='{{range $k,$v := .metadata.labels}}{{if eq $k "directpv.min.io/pod.namespace"}}{{$v}}{{end}}{{end}}'
}

# usage: get_node_name <drive-id>
function get_node_name() {
    # shellcheck disable=SC2016
    kubectl get directpvdrives "${1}" \
            -o go-template='{{range $k,$v := .metadata.labels}}{{if eq $k "directpv.min.io/node"}}{{$v}}{{end}}{{end}}'
}

# usage: is_uuid input
function is_uuid() {
    [[ "$1" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]
}

# usage: must_get_drive_id <node> <drive-name>
function must_get_drive_id() {
    if [ -z "${1}" ]; then
        print "node argument must be provided for drive name"
        exit 255
    fi
    # shellcheck disable=SC2207
    drive_ids=( $(get_drive_ids "${1}" "${2}") )
    if [ "${#drive_ids[@]}" -eq 0 ]; then
        printf 'drive '%s' on node '%s' not found' "$2" "$1"
        exit 255
    fi
    if [ "${#drive_ids[@]}" -gt 1 ]; then
        printf 'duplicate drive ids found for '%s'' "$2"
        exit 255
    fi
    drive_id="${drive_ids[0]}"
}

function init() {
    if [[ $# -lt 2 || $# -gt 3 ]]; then
        cat <<EOF
NAME:
  ${ME} - This script replaces source drive to destination drive in the specified node.

USAGE:
  ${ME} <SRC-DRIVE> <DEST-DRIVE> [NODE]

ARGUMENTS:
  SRC-DRIVE      Source drive by name or drive ID.
  DEST-DRIVE     Destination drive by name or drive ID.
  NODE           Valid node name. Should be provided if drive name is used to refer source/destination drive.

EXAMPLE:
  # Replace /dev/sdb by /dev/sdc on node worker4.
  $ ${ME} /dev/sdb /dev/sdc worker4

  # Replace detached /dev/sdb with drive ID 1bff96ba-f32e-4493-b95b-897c07d68460 by newly added /dev/sdb with 
  # drive ID 52bf469b-e62e-40b8-a23e-941cd7fe03b3 on worker3.
  $ ${ME} 1bff96ba-f32e-4493-b95b-897c07d68460 52bf469b-e62e-40b8-a23e-941cd7fe03b3
EOF
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
    src_drive="${1#/dev/}"
    dest_drive="${2#/dev/}"
    node="${3}"

    if [ "${src_drive}" == "${dest_drive}" ]; then
        echo "the source and destination drives are same"
        exit 255
    fi

    if ! is_uuid "${src_drive}"; then
        must_get_drive_id "${node}" "${src_drive}"
        src_drive_id="${drive_id}"
    else
        src_drive_id="${src_drive}"
    fi

    if ! is_uuid "${dest_drive}"; then
        must_get_drive_id "${node}" "${dest_drive}"
        dest_drive_id="${drive_id}"
    else
        dest_drive_id="${dest_drive}"
    fi

    if [ "${src_drive_id}" == "${dest_drive_id}" ]; then
        echo "the source and destination drive IDs are same"
        exit 1
    fi

    src_node=$(get_node_name "${src_drive_id}")
    if [ -z "${src_node}" ]; then
        echo "unable to find the node name of the source drive '${src_drive}'"
        exit 1
    fi

    dest_node=$(get_node_name "${dest_drive_id}")
    if [ -z "${dest_node}" ]; then
        echo "unable to find the node name of the destination drive '${dest_drive}'"
        exit 1
    fi

    if [ "${src_node}" != "${dest_node}" ]; then
        echo "the drives are not from the same node"
        exit 1
    fi

    # Cordon source and destination drives
    if ! kubectl directpv cordon "${src_drive_id}" "${dest_drive_id}"; then
        echo "unable to cordon drives"
        exit 1
    fi

    # Cordon kubernetes node
    if ! kubectl cordon "${src_node}"; then
        echo "unable to cordon node '${src_node}'"
        exit 1
    fi

    mapfile -t volumes < <(get_volumes "${src_drive_id}")
    IFS=' ' read -r -a volumes_arr <<< "${volumes[@]}"
    for volume in "${volumes_arr[@]}"; do
        pod_name=$(get_pod_name "${volume}")
        pod_namespace=$(get_pod_namespace "${volume}")

        if ! kubectl delete pod "${pod_name}" --namespace "${pod_namespace}"; then
            echo "unable to delete pod '${pod_name}' using volume '${volume}'; please delete the pod manually"
        fi
    done

    if [ "${#volumes_arr[@]}" -gt 0 ]; then
        # Wait for associated DirectPV volumes to be unbound
        while kubectl directpv list volumes --no-headers "${volumes_arr[@]}" | grep -q Bounded; do
            echo "...waiting for volumes to be unbound"
            sleep 10
        done
    else
        echo "no volumes found in source drive '${src_drive}' on node '${src_node}'"
    fi

    # Run move command
    kubectl directpv move "${src_drive_id}" "${dest_drive_id}"

    # Uncordon destination drive
    kubectl directpv uncordon "${dest_drive_id}"

    # Uncordon kubernetes node
    kubectl uncordon "${src_node}"
}

init "$@"
main "$@"
```
