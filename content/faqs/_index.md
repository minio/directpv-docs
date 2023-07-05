---
title: Frequently Asked Questions
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
heading: true
weight: 80
---

## What type of disks are recommended for DirectPV?

DirectPV is specifically meant for [Direct Attached Storage](https://en.wikipedia.org/wiki/Direct-attached_storage) such as hard drives and solid-state drives in a "JBOD" configuration (Just a Bunch of Disks). 

Avoid using DirectPV with SAN- and NAS-based storage options, as they inherently involve extra network hops in the data path. 
This leads to poor performance and increased complexity.

## How is DirectPV is different from LocalPV and HostPath?

HostPath volumes are ephemeral and are tied to the lifecycle of pods. 
Deleting or restarting a pod results in the removal of the HostPath volumes.
This causes the loss of any data stored on the volumes. 

DirectPV volumes persist through both node and pod reboots. 
The associated [Persistent Volume Claims](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) (PVC) manage the lifecycle of a DirectPV volume.

LocalPVs are statically provisioned from a local storage resource on the nodes that require persistent volumes.
You must create the required LocalPVs prior to the workloads using them. 
For LocalPV, you must provide extensive user management for all stages, including creating the actual object resource for LocalPV.

DirectPV also creates statically provisioned volume resources, but does not require user intervention for the creation of the object resource. 
Instead, DirectPV dynamically provisions the persistent volume in response to a PVC requesting a DirectPV storage volume. 
This significantly reduces complexity of management.

## How are the disks selected for a Pod?

DirectPV operates only on those disks which it [explicitly manages]({{< relref "command-line/init.md" >}}).

For these managed disks, DirectPV:

1. Selects disks local to the node where the pod is scheduled, providing direct access for the pods to the disks. 

2. Runs a [selection algorithm]({{< relref "volume-scheduling/_index.md" >}}) to choose a disk for a volume creation request.

3. Creates a sub-directory for the volume with quota set on the sub-directory for the requested volume size.

4. Publishes the volume to the pod.

## What does drive initialization do?

Use `kubectl directpv init` to prepare the drives by formatting them with XFS filesystem and mounting them in a desired path (`/var/lib/directpv/mnt/<uuid>`). 
After successful mounting, DirectPV can schedule volumes on these drives.
To see initialized drives, use `kubectl directpv list drives`.

## What are DirectPV's requirements to use a drive?

To initialize, a drive must have at least 512MB of space.
The drive **cannot** have any of the following characteristics:

- Hidden
  
  (`/sys/class/block/<device>/hidden` should not be "1".)
- Read-only
- Partitioned
- Held by other devices
 
  (`/sys/class/block/<device>/holders` should not have any entries.)
- Mounted
- Have swap-on enabled
- Be a CD-ROM

DirectPV supports any storage resource presenting itself as a block device. 
While this includes LVMs (logical volume management), LUKs (Linux Unified Keys), LUNs (logical unit numbers), and similar virtualized drives, we do not recommend using DirectPV with such devices in production environments.

## What does error "no drive found for requested topology" mean?

This error occurs in the following situations: 

- Kubernetes scheduled the pod on a node where DirectPV doesn't have any drives initialized. 
  To correct this, use selectors in the workload to have Kubernetes schedule the pods on the desired set of nodes. 
  Refer to the [Kubernetes documentation on assigning pods to nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) for more details.
- You requested a zone, size, or other such parameter that DirectPV cannot satisfy with an available initialized drive on the selected node.
  To correct this, change the parameter(s) in the workloads to an available set of values.

## Is `direct-csi-min-io` storage class still supported?

No, DirectPV v4.0.0 and later removed support for `direct-csi-min-io`. 
After this release, DirectPV does not provision any new volumes using the `direct-csi-min-io` storage class. 
However, the latest versions of DirectPV continue to manage any existing volumes already provisioned using the `direct-csi-min-io` storage class.

To provision new volumes, use the `directpv-min-io` storage class. 
There are no functional or behavioral differences between `direct-csi-min-io` and `directpv-min-io`.

## Does DirectPV support volume snapshotting?

No, DirectPV doesn't support CSI snapshotting. 
DirectPV is specifically meant for use cases where the application takes care of data availability and resiliency, such as [MinIO](https://min.io/?ref=directpv-docs). 
Applications using With the AWS S3 versioning APIs and internal healing do not require snapshots.

## Does DirectPV support `ReadWriteMany`?

No, DirectPV does not support `ReadWriteMany`.
DirectPV only supports `ReadWriteOnce`.

The workloads using DirectPV run local to the node. 
DirectPV provisions volumes from disks local in the node. 
This allows workloads to access the data path directly without any additional network hops, unlike remote volumes (network PVs). 

Additional network hops from networked persistent volumes increases the complexity of the workload and may lead to poor performance. 