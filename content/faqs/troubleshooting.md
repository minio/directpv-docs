---
title: Troubleshooting
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
weight: 200
---

## DirectPV installation fails in my Kubernetes. Why?
You need to have necessary privileges and permissions to perform installation. Go though the [specifications documentation](./specifications.md). For Red Hat OpenShift, refer to the [OpenShift specific documentation](./openshift.md). 

## After upgrading DirectPV to v4.x.x, I do not find `direct-csi-min-io` storage class. Why?
Legacy DirectCSI is deprecated including storage class `direct-csi-min-io` and it is no longer supported. Previously created volumes continue to work normally. For new volume requests, use the `directpv-min-io` storage class.

## In the YAML output of `discover` command, I do not find my storage drive(s). Why?
DirectPV ignores drives that meet any of the below conditions:
* The size of the drive is less than 512MiB.
* The drive is hidden.
* The drive is read-only.
* The drive is parititioned.
* The drive is held by other devices.
* The drive is mounted or in use by DirectPV already.
* The drive is in-use swap partition.
* The drive is a CDROM.

Check the last column of the `discover --all` command output to see what condition(s) exclude the drive. Resolve the conditions and try again.

## Do you support SAN, NAS, iSCSI, network drives etc.,?

DirectPV is meant for high performance local volumes with Direct Attached Storage. 
We do not recommend any remote drives, as remote drives may lead to poor performance.

## Do you support LVM, Linux RAID, Hardware RAID, Software RAID, or similar?

It works, but we strongly recommend to use raw devices for better performance.

## Is LUKS device supported?

Yes

## I am already using Local Persistent Volumes (Local PV) for storage. Why do I need DirectPV?

Local Persistent Volumes are ephemeral and are tied to the lifecyle of pods. 
These volumes are lost when a pod is restarted or deleted which may lead to data loss. 

Additionally, Local Persistent Volumes lifecycle requires administrative skills. 
DirectPV dynamically provisions volumes on-demand that are persistent through pod/node restarts. 
The lifecycle of DirectPV volumes are managed by associated Persistent Volume Claims (PVCs), simplifying volume management.

## I see `no drive found ...` error message in my Persistent Volume Claim. Why?

The table below lists possible reasons and solutions.

| Reason                                                       | Solution                                |
|:-------------------------------------------------------------|:----------------------------------------|
| Volume claim is made without adding any drive into DirectPV. | Add drives.                             |
| No drive has free space for requested size.                  | Add new drives or remove stale volumes. |
| Requested topology is not met.                               | Modify Persistent Volume Claim.         |
| Requested drive is not found on the requested node.          | Modify Persistent Volume Claim.         |
| Requested node is not DirectPV node.                         | Modify Persistent Volume Claim.         |

## I see Persistent Volume Claim is created, but respective DirectPV volume is not created. Why?

DirectPV comes with [WaitForFirstConsumer](https://kubernetes.io/docs/concepts/storage/storage-classes/#volume-binding-mode) volume binding mode.
This means that a Pod to consume the volume must be scheduled first.

## I see volume consuming Pod still in `Pending` state. Why?

* If you haven't created the respective Persistent Volume Claim, create it.
* You may be facing Kubernetes scheduling problem. 
  Refer to the Kubernetes documentation [on scheduling](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)

## I see `volume XXXXX is not yet staged, but requested with YYYYY` error. Why?

According to CSI specification, `Kubelet` should call `StageVolume` RPC first, then `PublishVolume` RPC next. 
In a rare event, `StageVolume` RPC is not fired/called, but `PublishVolume` RPC is called. 
Restart your Kubelet and report this issue to your Kubernetes provider.

## I see a `udev` error. Why?

You may very rarely see a `udev` error:

```sh
unable to find device by FSUUID xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx; either device is removed or run command `sudo udevadm control --reload-rules && sudo udevadm trigger` on the host to reload
```

In a rare event, `Udev` in your system missed updating `/dev` directory. 
Run the following command to update and reload `udev`, then report this issue to your OS vendor.

```sh {.copy}
sudo udevadm control --reload-rules && sudo udevadm trigger
```