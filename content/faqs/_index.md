---
title: Frequently Asked Questions
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
heading: true
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

DirectPV operates only on those disks which it [explicitly manages]({{< relref "command-line/cli.md#initialize-the-available-drives-present-in-the-cluster" >}}).

For these managed disks, DirectPV:

	1. Selects disks local to the node where the pod is scheduled, providing direct access for the pods to the disks. 

	2. Runs a selection algorithm to choose a disk for a volume creation request.

	3. Creates a sub-directory for the volume with quota set on the sub-directory for the requested volume size.

	4. Publishes the volume to the pod.

 For more details on how DirectPV manages and selects disks, see [volume scheduling]({{< relref "volume-scheduling/_index.md" >}})

## What does drive initialization do?

DirectPV command `kubectl directpv init` command will prepare the drives by formatting them with XFS filesystem and mounting them in a desired path (/var/lib/directpv/mnt/<uuid>). 
Upon success, these drives will be ready for volumes to be scheduled and you can see the initialized drives in `kubectl directpv list drives`.

## What are the conditions that a drive must satisfy to be used for DirectPV?

A drive must meet the following requirements for it to be used for initialization

- The size of the drive should not be less then 512MiB.
- The drive must not be hidden. (Check /sys/class/block/<device>/hidden, It should not be "1")
- The drive must not be a read-only.
- The drive must not be partitioned.
- The drive must not be held by other devices. (Check /sys/class/block/<device>/holders, It should not have any entries)
- The drive must not be mounted.
- The drive must not have swap-on enabled.
- The drive must not be a CD-ROM.

DirectPV can support any storage resource presenting itself as a block device. While this includes LVMs, LUKs, LUNs, and similar virtualized drives, we do not recommend using DirectPV with those in production environments.

## What does error "no drive found for requested topology" mean?

This error can be seen in PVC and pod description when 

- Kubernetes scheduled the pod on a node where DirectPV doesn't have any drives initialized. This can be fixed by using necessary selectors in the workload to make k8s schedule the pods on the correct set of nodes. Please refer [here](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) to know more on assigning the pod to specific nodes.
- The requested topology specifications like size, zone etc cannot be satisfied by any of initialized drives in the selected node. This can be fixed by changing the topology parameter in the workloads to suitable value.

## Is `direct-csi-min-io` storage class still supported?

No, the support for `direct-csi-min-io` is removed from DirectPV version v4.0.0. No new volumes will be provisioned using `direct-csi-min-io` storage class. However, the existing volumes which are already provisioned by `direct-csi-min-io` storage class will still be managed by the latest DirectPV versions.

Alternatively, you can use `directpv-min-io` storage class for provisioning new volumes. And there are no functional or behavioral differences between 'direct-csi-min-io' and 'directpv-min-io'.

## Does DirectPV support volume snapshotting?

No, DirectPV doesn't support CSI snapshotting. DirectPV is specifically meant for use cases like MinIO where the data availability and resiliency is taken care by the application itself. Additionally, with the AWS S3 versioning APIs and internal healing, snapshots isn't required.

## Does DirectPV support `ReadWriteMany`?

No, DirectPV doesn't support `ReadWriteMany`. The workloads using DirectPV run local to the node and are provisioned from local disks in the node. This makes the workloads to directly access the data path without any additional network hops unlike remote volumes (network PVs). The additional network hops may lead to poor performance and increases the complexity. So, DirectPV doesn't support `ReadWriteMany` and only supports `ReadWriteOnce`.