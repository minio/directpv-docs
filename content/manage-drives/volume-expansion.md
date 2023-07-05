---
title: Volume Expansion
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

{{< admonition type="note" >}}
Added in version 3.2.2.
{{< /admonition >}}

## Overview

DirectPV supports the volume expansion [CSI feature](https://kubernetes-csi.github.io/docs/volume-expansion.html). 
With this support, you can expand DirectPV provisioned volumes to the requested size claimed by the Persistent Volume Claim (PVC). 
DirectPV supports online volume expansion where workloads do not have any downtimes during the expansion process.

Volume expansion requires that you have the `ExpandCSIVolumes` feature gate enabled.
This feature is enabled by default in Kubernetes v1.16 and above. 
For more details on the feature gates, see the [Kubernetes documentation](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/).

## Procedure

To expand the volume, edit the `spec.resources.requests.storage` size in the corresponding PVC spec.

```yaml
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: <new-size> # Set the new size here
  storageClassName: directpv-min-io
  volumeMode: Filesystem
  volumeName: pvc-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

After the edits, DirectPV expands the volume and reflects the new size when displaying info about the volume.
You can check the volume information with the `directpv list` command.

```sh {.copy}
`kubectl directpv list volumes pvc-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -o wide`. 
```

The corresponding PVC remains in "Bounded" state with the expanded size.

There is no need to restart workload pods.
