---
title: Upgrade DirectPV
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

{{< admonition title="Updating Custom Installations" type="important" >}}
Custom installations do not support client-side upgrade functionality. 
Use [`kubectl directpv migrate`]({{< relref "/command-line/migrate.md" >}}) to migrate the old resources to a new installation.
{{< /admonition >}}

{{< admonition title="Pod Security Policies" type="note" >}}
Kubernetes deprecated the `PodSecurityPolicy` feature in v1.21, then removed it entirely in v1.25.
Use [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/) as a replacement, as recommended in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/security/pod-security-policy/).

DirectPV continues to support `PodSecurityPolicy` in the 4.0.x versions.
DirectPV 4.1.x and later removed support for `PodSecurityPolicy`.
{{< /admonition >}}

## Version support

### 4.1.x

Releases in the **4.1.x** series are the latest of the open source DirectPV CSI Driver.

Most users should install or upgrade to the latest release in the **4.1.x** series.

However, if you require continued use of the deprecated `PodSecurityPolicy` feature, be sure to follow the upgrade guide carefully.

### 4.0.x

The **4.0.x** series entered maintenance mode on January 1, 2025.

Maintenance may include limited bug or security resolution.
Users should plan to migrate to the 4.1.x series at the earliest opportunity.

### Earlier releases

Versions older than 4.0.0 are no longer supported.

## Upgrade DirectPV CSI Driver from 4.x.x to latest

### Offline upgrade

Follow the steps below to perform an offline upgrade:

1. Uninstall the DirectPV CSI driver.
   
   This does not remove any existing resources.

   ```sh {.copy}
   kubectl directpv uninstall
   ```
2. Upgrade the DirectPV plugin.

   ```sh
   kubectl krew upgrade directpv
   ```

   If you use the binary instead of `krew`, download the latest binary for your operating system and architecture.

3. [Install the latest DirectPV CSI driver]({{< relref "/installation/_index.md#driver-installation" >}}).

### In-place upgrade

Follow the steps below to perform an in-place upgrade:

1. Use the following command to upgrade the DirectPV `krew` plugin:

   ```shb {.copy}
   kubectl krew upgrade directpv
   ```

   If you use the binary instead of `krew`, download the latest binary for your operating system and architecture.


2. Run the install script with the appropriate node-selector, tolerations, and `KUBELET_DIR_PATH` environment variables needed for your environment.

   ```sh {.copy}
   curl -sfL https://github.com/minio/directpv/raw/master/docs/tools/install.sh | sh -s - apply
   ```

### Retain PodSecurityPolicy support

If you upgrade to 4.1.x and wish to retain support for `PodSecurityPolicy`, complete the following steps.

#### Before starting the upgrade

Make a backup of the existing `psp` and `clusterrolebinding` YAML specifications.

```sh {.copy}
kubectl get psp directpv-min-io -o yaml > psp.yaml
kubectl get clusterrolebinding psp-directpv-min-io -o yaml > psp-crb.yaml
```

#### Apply the backup YAML

After completing the other upgrade steps, apply the `psp` and `clusterrolebinding` YAML backups.

```sh {.copy}
kubectl apply -f psp.yaml
kubectl apply -f psp-crb.yaml
```

## Upgrade legacy DirectCSI driver

For older versions, upgrade to v3.2.2 before upgrading to the latest version.

In the latest version of DirectPV, the CSI sidecar images have been updated. 

1. If you are upgrading from 3.1.0 or later, uninstall the existing DirectCSI driver.

   Uninstalling DirectPV does not remove any resources.

   ```sh {.copy}
   kubectl directcsi uninstall
   ```

   If you are upgrading from an older version, you will do this step later in the process.

2. Upgrade or install the latest version of the DirectPV plugin.
   
   ```sh {.copy}
   kubectl krew upgrade directpv
   ```

   If you have not upgraded from Direct CSI to DirectPV, use the following instead:

   ```sh {.copy}
   kubectl krew install directpv
   ```
  
3. _(Optional)_ If you are using custom storage classes for scheduling **and** you are upgrading from a version < v4.0.0, you **must** modify the storage class parameters.

   Change `direct.csi.min.io/access-tier: <your_access_tier_value>` to `directpv.min.io/access-tier: <your_access_tier_value>` in the respective storage class parameters section.

4. Install the updated version of Direct-CSI.
   
   ```sh {.copy}
   kubectl directpv install
   ```

   For more details on the installation process or custom installation methods, refer to the [nstallation documentation]({{< relref "/installation/_index.md" >}}).

5. If you are upgrading from a version older that 3.1.0, uninstall the DirectCSI driver.

   ```sh {.copy}
   kubectl directcsi uninstall
   ```

6. Check that the pods are running.
   
   ```sh {.copy}
   kubectl get pods -n direct-csi-min-io -w
   ```

7. Verify you can reach the DirectPV drives.
   
   ```sh {.copy}
   kubectl directpv drives ls
   ```

### Cleaning Up Post-Upgrade

The older CRDs (`directcsidrives` and `directcsivolumes`) are deprecated and not used in versions > v4.0.0.
These can be removed after upgrading. 

Use the following Bash script to remove the older objects after upgrading to latest.

```bash {.copy}
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
# This script removes direct-csi drives and volumes after taking backup YAMLs
# to directcsidrives.yaml and directcsivolumes.yaml
#

set -e -C -o pipefail

function init() {
    if [[ $# -ne 0 ]]; then
        echo "usage: remove-directcsi.sh"
        echo
        echo "This script removes direct-csi drives and volumes after taking backup YAMLs"
        echo "to directcsidrives.yaml and directcsivolumes.yaml"
        exit 255
    fi

    if ! which kubectl >/dev/null 2>&1; then
        echo "kubectl not found; please install"
        exit 255
    fi
}

# usage: unset_object_finalizers <resource>
function unset_object_finalizers() {
    kubectl get "${1}" -o custom-columns=NAME:.metadata.name --no-headers | while read -r resource_name; do
        kubectl patch "${1}" "${resource_name}" -p '{"metadata":{"finalizers":null}}' --type=merge
    done
}

function main() {
    kubectl get directcsivolumes -o yaml > directcsivolumes.yaml
    kubectl get directcsidrives -o yaml > directcsidrives.yaml

    # unset the finalizers
    unset_object_finalizers "directcsidrives"
    unset_object_finalizers "directcsivolumes"
    
    # delete the resources
    kubectl delete directcsivolumes --all
    kubectl delete directcsidrives --all
}

init "$@"
main "$@"
```

## Upgrade from versions < v3.2.x

If you are on DirectCSI version < 3.2.2, first upgrade to v3.2.2, then upgrade to the latest version.

1. Uninstall the existing setup.

   Uninstalling DirectPV does not remove any resources.

   ```sh {.copy}
   kubectl direct-csi uninstall
   ```

2. Confirm the deletion of the CSI pods.

   ```sh {.copy}
   kubectl get pods -n direct-csi-min-io
   ```
  
   DirectPV v4.0.0 and later do not use the `direct-cs-min-io` namespace when creating new drives or volumes.
   However, the latest versions of DirectPV can continue to use resources already existing in that namespace.

3. Download Direct-CSI v3.2.2 from https://github.com/minio/directpv/releases/tag/v3.2.2.

4. Load the following images:

   ```text {.copy}
   quay.io/minio/csi-provisioner:v2.2.0-go1.18
   quay.io/minio/csi-node-driver-registrar:v2.2.0-go1.18
   quay.io/minio/livenessprobe:v2.2.0-go1.18
   ```
  
   If your kubernetes version is less than v1.20, also push `quay.io/minio/csi-provisioner:v2.2.0-go1.18`

5. Install the updated version of Direct-CSI.
   
   ```sh {.copy}
   kubectl direct-csi install
   ```

6. Check that the pods are running.
   
   ```sh {.copy}
   kubectl get pods -n direct-csi-min-io -w
   ```

7. Verify you can reach the DirectPV drives.
   
   ```sh {.copy}
   kubectl direct-csi drives ls
   ```

   ## Upgrade DirectPV Plugin

   To upgrade the plugin using `krew`, use the following command.

   ```sh {.copy}
   kubectl krew upgrade directpv
   ```

   To upgrade from a binary, follow the [binary installation instructions]({{< relref "/installation/_index.md#install-directpv-plugin-as-a-binary" >}}).