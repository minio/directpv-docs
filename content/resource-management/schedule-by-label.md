---
title: Schedule Volumes by Label
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
weight: 60
---

## Volume scheduling based on drive labels

DirectPV offers multiple ways to restrict how volumes schedule to drives:

- Available drive space
- Node topology with affinity and anti-affinity and similar tools
- User-defined drive labels
 
You can assign labels to classify types of drives.
Once assigned, use those labels in storage class parameters to select the desired types.

By default, the DirectPV drives do not have any user-defined labels set on them. 
Use `kubectl directpv label drives` to set user-defined labels for DirectPV drives.

{{< admonition type="note" >}}

Labeling only limits scheduling when creating new volumes as this is a schedule time process.
{{< /admonition >}}

## Tutorial

{{< admonition type="note">}}
Throughout this tutorial, replace the place holders `<label-key>`,`<label-value>` and `<drive-name>` with appropriate values based on the classification you chose
{{< /admonition >}}

1. Set the label on the DirectPV drive(s).

   ```sh {.copy}
   kubectl directpv label drives <label-key>=<label-value> --drives /dev/<drive-name>
   ```

2. Verify that the labels are properly set by using the `list` command with the `--show-labels` flag.

   ```sh {.copy}
   kubectl directpv list drives --drives /dev/<drive-name> --show-labels
   ```

3. Create or modify the storage class definition.
 
   Set a `parameter` value in the definition YAML.
   The value should follow the form `directpv-min-io/<label-key>: <label-value>`.
   
   ```yaml {.copy}
   parameters:
     directpv.min.io/<label-key>: <label-value>
   ```

   {{< admonition type="tip" >}}
   Refer to the default storage class `kubectl get storageclass directpv-min-io -n directpv -o yaml` to compare and check if all the fields are present on the new storage class.
   {{< /admonition >}}
   
   The following YAML is an example of a storage class definition that includes a `parameters` section:
   
   ```yaml {.copy}
   allowVolumeExpansion: false
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
     name: directpv-min-io-new # Define any storage class name of your choice
     resourceVersion: "511457"
     uid: e93d8dab-b182-482f-b8eb-c69d4a1ec62d
   parameters:
     fstype: xfs
     directpv.min.io/<label-key>: <label-value>
   provisioner: directpv-min-io
   reclaimPolicy: Delete
   volumeBindingMode: WaitForFirstConsumer
   ```

4. Deploy the workload with the new storage class name set.

   Volumes are only placed on the labeled drives. 
   You can verify this with the following command:
   
   ```sh {.copy}
   kubectl directpv list drives --labels <label-key>:<label-value>
   kubectl directpv list volumes
   ```
