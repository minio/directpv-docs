---
title: Architecture
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

DirectPV is implemented according to the [CSI specification](https://github.com/container-storage-interface/spec/blob/master/spec.md). 
It comes with the below components run as Pods in Kubernetes:
* `Controller`
* `Node server`

When DirectPV contains legacy volumes from `DirectCSI`, the following additional components also run as Pods:
* `Legacy controller `
* `Legacy node server`

## Controller

![Diagram showing the flow of events from a Persistent Volume Claim through the CSI Provisioner or CSI Resizer to the Controller Server and finally to changes in either the DirectPVDrive CRD or the DirectPVVolume CRD](../PVC-events.png)

The Controller runs as `Deployment` Pods named `controller`.
These are three replicas located in any Kubernetes nodes. 
The replicas elect one instance to serve requests. 

Each pod has the following containers:

* `Controller` 
 
  Honors CSI requests to create, delete and expand volumes.

* `CSI provisioner`

  Bridges volume creation and deletion requests from a `Persistent Volume Claim` to the CSI controller.

* `CSI resizer` 
 
  Bridges volume expansion requests from `Persistent Volume Claim` to CSI controller.

### Controller server

The controller server runs as a container `controller` in a `controller` `Deployment` Pod. 

It handles the following requests:

* `Create volume`

  The controller server creates a new `DirectPVVolume` CRD after reversing requested storage space on a suitable `DirectPVDrive` CRD. 
  For more information, refer to the [Volume scheduling guide]({{< relref "/resource-management/scheduling.md" >}}).

* `Delete volume`
  
  The controller server deletes an existing `DirectPVVolume` CRD for unbound volumes after releasing previously reserved space in a  `DirectPVDrive` CRD.

* `Expand volume`
 
  The controller server expands an existing `DirectPVVolume` CRD after reversing requested storage space in a `DirectPVDrive` CRD.

## Legacy controller

![Diagram showing the flow of events from a persistent volume claim using the legacy style direct-csi-min-io storage class through the CSI provisioner or CSI REsizer to the Controller Server and finally either the DirectPVDrive CRD or the DirectPVVolume CRD](../legacy-pvc-events.png)

The Legacy controller runs as `Deployment` Pods named `legacy-controller`.
These pods are three replicas located in any Kubernetes nodes. 
The three replicas elect one instance to serve requests. 

Each pod has the following containers:

* `CSI provisioner`
 
  Bridges legacy volume creation and deletion requests from `Persistent Volume Claim` to the CSI controller.

* `Controller` 
 
  Honors CSI requests to delete and expand volumes only. 
  Create volume requests are prohibited. 
  The legacy controller works only for legacy volumes previously created in `DirectCSI`.

* `CSI resizer`
 
  Bridges legacy volume expansion requests from `Persistent Volume Claim` to the CSI controller.

### Legacy controller server

The kegacy controller server runs as a container `controller` in a `legacy-controller` `Deployment` Pod. 
It handles the following requests:

* `Create volume` 
 
  The Controller server errors out for this request. 
  DirectPV does not create new legacy DirectCSI volumes.

* `Delete volume`
 
  The Controller server deletes the `DirectPVVolume` CRD for unbound volumes after releasing previously reserved space in the `DirectPVDrive` CRD.

* `Expand volume`
 
  The Controller server expands the `DirectPVVolume` CRD after reversing requested storage space in the `DirectPVDrive` CRD.

## Node server

![Diagram showing the flow of events from kubelet to the Node Server, the actions taken by event type, and updating the DirectPVDrive CRD or DirectPVVolume CRD](../node-server.png)

The node server runs as `DaemonSet` Pods named `node-server` in all or selected Kubernetes nodes. 
Each node server Pod runs on a node independently. 

Each pod has the following containers:

* `Node driver registrar` 
 
  Registers node server to kubelet to get CSI RPC calls.

* `Node server` 
 
  Honors `stage`, `unstage`, `publish`, `unpublish` and `expand` volume RPC requests.

* `Node controller` 
 
  Honors CRD events from `DirectPVDrive`, `DirectPVVolume`, `DirectPVNode` and `DirectPVInitRequest`.

* `Liveness probe` 
 
  Exposes a `/healthz` endpoint to check node server liveness by Kubernetes.

## Legacy node server

The legacy node server runs as `DaemonSet` Pods named `legacy-node-server` in all or selected Kubernetes nodes. 
Each legacy node server Pod runs on a node independently. 

Each pod contains the below running containers:

* `Node driver registrar` 
 
  Registers legacy node server to kubelet to get CSI RPC calls.

* `Node server` 
 
  Honors `stage`, `unstage`, `publish`, `unpublish` and `expand` volume RPC requests.

* `Liveness probe` 
 
  Exposes `/healthz` endpoint to check legacy node server liveness by Kubernetes.


<!--

*****************

## Components

DirectPV has 5 components:

1. **CSI Driver**
   Mounts or unmounts provisioned volumes
2. **CSI Controller**
   Schedules and detaches volumes on nodes 
3. **Drive Controller**
   Formats and manages drive lifecycle
4. **Volume Controller**
   Manages volume lifecycle
5. **Drive Discovery** 
   Discovers drives and monitors their status on nodes

These components run on two pods in the Kubernetes environment:

1. **DirectPV Node Driver DaemonSet**
   Contains the CSI Driver, Driver Controller, Volume Controller, and Drive Discovery as a [daemonset](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
2. **DirectPV Central Controller**
   Runs the CSI Controller as a [deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

## Scalability

The Node Driver DaemonSet runs on each node, performing only operations specific to its node.

The Central Controller deployment should scale up as the number of drives managed by DirectPV increases. 
By default, DirectPV runs 3 replicas of the Central Controller. 
As a general guideline for high scale performance, have as many Central Controller replicas as you have etcd nodes.

## Availability

If a node's Node Driver DaemonSet is down, then volume mounting, unmounting, formatting and cleanup cannot proceed for volumes and drives on that node. 
In order to restore operations, restore the Node Driver DaemonSet to running status.

If the Central Controller deployment is down, then volume scheduling and deletion cannot proceed for any volume or drives throughout the entire DirectPV cluster. 
To restore operations, bring the Central Controller to running status.

## Security

For information on security in DirectPV, see the [security policy on GitHub](https://github.com/minio/directpv/security/policy).

## Node Driver

The Node Driver runs on every node in the `directpv` namespace as a [daemonset](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). 
Each pod consists of four containers for the CSI Driver, Driver Controller, Volume Controller, and Drive Discovery.

### Node Driver Registrar

The Node Driver Registrar works as a Kubernetes CSI sidecar container to register the `directpv` CSI driver with [kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/). 
This registration is necessary for kubelet to issue CSI Remote Procedure Calls (RPCs) like `NodeGetInfo`, `NodeStageVolume`, `NodePublishVolume` to the corresponding nodes.

For more details, please refer to [node driver registrar](https://github.com/kubernetes-csi/node-driver-registrar) in the Kubernetes repository.

### Livenessprobe

This Kubernetes CSI sidecar container exposes an HTTP `/healthz` endpoint as a liveness hook. 
Kubernetes uses this endpoint to perform CSI Driver liveness checks.

For more details, see the [Kubernetes CSI repository on livenessprobe](https://github.com/kubernetes-csi/livenessprobe)

### Dynamic Drive Discovery

DirectPV utilizes the Dynamic Drive Discovery container to discover and manage drives in the node.
Enable this container by using the `--dynamic-drive-handler` flag.

The Dynamic Drive Discovery container monitors the `/run/data/udev/` directory and dynamically listens for [udev](https://en.wikipedia.org/wiki/Udev) events for any uevents that add, change or remove drives. 
Apart from dynamically listening, the container also periodically checks and syncs the drive states.

DirectPV creates a `directcsidrive` object when it detects a new device during sync or in response to an `Add` uevent. 
For any change, the `directcsidrive` object syncs to match the local state. 
A drive in either an `inuse` or `ready` state gets corrupted or lost, the `directcsidrive` object tags the drive with an error condition. 
A drive with a state of `Available` or `Unavailable` becomes lost, the `directcsidrive` object deletes the drive.

### DirectPV

This container acts as a node plugin and implements the following node service Remote Procedure Calls (RPCs).

- [NodeGetInfo](https://github.com/container-storage-interface/spec/blob/master/spec.md#nodegetinfo)
- [NodeGetCapabilities](https://github.com/container-storage-interface/spec/blob/master/spec.md#nodegetinfoNodeGetCapabilities)
- [NodeGetVolumeStats](https://github.com/container-storage-interface/spec/blob/master/spec.md#nodegetvolumestats)
- [NodeStageVolume](https://github.com/container-storage-interface/spec/blob/master/spec.md#nodestagevolume)
- [NodePublishVolume](https://github.com/container-storage-interface/spec/blob/master/spec.md#nodepublishvolume)
- [NodeUnstageVolume](https://github.com/container-storage-interface/spec/blob/master/spec.md#nodeunstagevolume)
- [NodeUnpublishVolume](https://github.com/container-storage-interface/spec/blob/master/spec.md#nodeunpublishvolume)

This container performs bind-mounting and unmounting of volumes on the responding nodes. 
For details on the lifecycle of a volume, refer to the [CSI spec](https://github.com/container-storage-interface/spec/blob/master/spec.md#volume-lifecycle).

The DirectPV container also provides drive and volume controllers, as detailed below.

{{< admonition title="Volume Monitoring" type="note" >}}
For information on monitoring DirectPV volumes, see [metrics]({{< relref "concepts/metrics.md" >}}).
{{< /admonition >}}

### Drive Controller

The Drive Controller manages the `directpvdrives` object lifecycle by actively listening for drive object (post-hook) events like `Add`, `Update` and `Delete`.

The Drive Controller performs the following actions:

- Formatting a drive

  When the drive object has `.Spec.RequestedFormat` set, the drive controller formats the drive.
  To set `.Spec.RequestedFormat`, run `kubectl directpv drives format`.

- Releasing a drive

  The Drive Controller releases an `Ready` drive when the `.Status.DriveStatus` indicates `Released`.
  This action changes the status of the drive from `Ready` to `Available`.

  To set `.Status.DriveStatus` to `Released`, run `kubectl directpv drives release` on a drive in `Ready` status.

- Checking the primary mount of the drive

  Drive controller also checks for the primary drive mounts. 
  The Drive Controller remounts drives with correct mount points and mount options in the following situations:

  - An `InUse` or `Ready` drive is not mounted
  - If an `InUse` or `Ready` drive has unexpected mount options
  
- Tagging the lost drives

  When the Drive Controller cannot locate a drive on the host, the Drive Controller tags the drive as `lost` with an error message attached to the drive object and its respective volume objects.

Overall, the Drive Controller validates and tries to sync the host state of the drive to match the expected state of the drive. 
For example, it mounts the `Ready` and `InUse` drives if their primary mount is not present in the host.

### Volume Controller

The Volume Controller manages the `directpvvolumes` object lifecycle by actively listening for volume object (post-hook) events like `Add`, `Update` and `Delete`. 

The volume controller is responsible for the following:

- Releasing/Purging deleted volumes and free-ing up its space on the drive

  When an action deletes or purges a volume (PVC deletion or using the `kubectl directpv drives purge` command), the corresponding volume object changes to a terminating state with a deletion timestamp set on it. 
  The volume controller looks for deleted volume objects and releases them by freeing up the disk space and unsetting the finalizers.

## Central Controller

The Central Controller runs as a deployment in the `directpv` namespace with a default replica count or `3`.

{{< admonition type="note" >}}
The Central Controller does not do any device level interactions in the host.
{{< /admonition >}}


Each pod consist of two containers.

1. CSI Provisioner
2. DirectPV

### CSI Provisioner

The CSI Provisioner is a Kubernetes CSI sidecar container responsible for sending volume provisioning (`CreateVolume`) and volume deletion (`DeleteVolume`) requests to CSI drivers.

For more details, please refer to the Kubernetes CSI documentation on [external provisioner](https://github.com/kubernetes-csi/external-provisioner).

### DirectPV

The DirectPV container acts as a central controller and implements the following RPCs

- [CreateVolume](https://github.com/container-storage-interface/spec/blob/master/spec.md#createvolume)
- [DeleteVolume](https://github.com/container-storage-interface/spec/blob/master/spec.md#deletevolume)

The DirectPV container selects a suitable drive for a volume scheduling request. 
The [selection algorithm]({{< relref "/resource-management/scheduling.md#drive-selection" >}}) looks for range and topology specifications provided in the `CreateVolume` request and selects a drive based on its free capacity.

{{< admonition type="note" >}}
The `kube-scheduler` maintains responsibility for selecting a node for a pod.
The Central Controller only selects a suitable drive in the requested node based on the specifications provided in the `CreateVolume` request.
{{< /admonition >}}

-->