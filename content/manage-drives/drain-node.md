---
title: Draining Nodes
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Description

Draining a node forcefully removes the DirectPV resources from the node. 
Use the [bash script](#bash-script) provided below for draining.

{{< admonition title="Irreversible" type="caution" >}}
Execute a drain with caution as it is an irreversible operation and may incur data loss.
{{< /admonition >}}

You can consider draining a node in the following circumstances:

- **When a node is detached from Kubernetes**

  If a node which was used by DirectPV is detached from Kubernetes, the DirectPV resources from that node remain intact until the resources are drained.

  The resources from the detached node can then be cleaned up by running the [bash script](#bash-script):

  ```sh {.copy}
  ./drain.sh <node-name>
  ```

- **When DirectPV is unselected to run on a specific node**

  If a node which was used by DirectPV is decided to be a "non-storage" node.

  For example, if you installed DirectPV with node selectors as in the following example:

  ```sh
  $ kubectl directpv uninstall
  $ kubectl directpv install --node-selector node-label-key=node-label-value
  ```

## Bash Script

Copy the following to a file named `drain.sh`.

Invoke the script with the following command:

```sh {.copy}
./drain.sh <node-name>
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

#
# This script drains the DirectPV resources from a selected node
# 
# **CAUTION**
#
# This operation is irreversible and may incur data loss if not used cautiously.
#

set -e -C -o pipefail


function drain() {
    selector="directpv.min.io/node=${2}"

    # unset the finalizers
    kubectl get "${1}" --selector="${selector}" -o custom-columns=NAME:.metadata.name --no-headers | while read -r resource_name; do
        kubectl patch "${1}" "${resource_name}" -p '{"metadata":{"finalizers":null}}' --type=merge
    done
    
    # delete the objects
    kubectl delete "${1}" --selector="${selector}" --ignore-not-found=true
}

function init() {

    if [[ $# -ne 1 ]]; then
        echo "usage: drain.sh <NODE>"
        echo
        echo "This script forcefully removes all the DirectPV resources from the node"
        echo "This operation is irreversible and may incur data loss if not used cautiously."
        exit 255
    fi

    if ! which kubectl >/dev/null 2>&1; then
        echo "kubectl not found; please install"
        exit 255
    fi

    if kubectl get csinode "${1}" -o go-template="{{range .spec.drivers}}{{if eq .name \"directpv-min-io\"}}{{.name}}{{end}}{{end}}" --ignore-not-found | grep -q .; then
        echo "the node is still under use by DirectPV CSI Driver; please remove DirectPV installation from the node to drain"
        exit 255
    fi
}

function main() {
    node="$1"

    drain "directpvvolumes" "${node}"
    drain "directpvdrives" "${node}"
    drain "directpvinitrequests" "${node}"
    kubectl delete directpvnode "${node}" --ignore-not-found=true
}

init "$@"
main "$@"
```
