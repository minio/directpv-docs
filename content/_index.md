---
title: MinIO DirectPV
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

This set of pages describes [MinIO DirectPV](https://github.com/minio/directpv), an AGPL3.0-licensed Container Storage Interface (CSI) for direct attached storage.

DirectPV consists of two primary components:

1. The **DirectPV CSI Driver** installed directly to the Kubernetes cluster that provisions local volumes
2. The **DirectPV Plugin** installed on the local machine to manage the DirectPV CSI Driver through the command line interface

At the basic level, DirectPV is a distributed persistent volume manager.
DirectPV is not a storage system like a SAN (Storage Area Network) or a NAS (Network Attached Storage). 
Instead, you use DirectPV to discover, format, mount, schedule and monitor drives across servers in a distributed environment.

DirectPV uses these mounted drives to create [persistent volumes (PV)](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) that Kubernetes uses to fulfill persistent volume claims (PVCs).

<!---
DirectPV exists to address an issue in Kubernetes where `hostPath` and local persistent volumes are statically provisioned and limited in functionality.
-->

Distributed data stores such as object storage, databases, and message queues benefit the most from direct attached storage.
These solutions, built for the distributed environment, should handle high availability and data durability by themselves. 
Running such data stores on traditional SAN- or NAS-based CSI drivers adds an unnecessary layer of replication or erasure coding, resulting in extra network hops in the data path. 
Such additional layers of disaggregation result in increased complexity and poor performance.

![Diagram comparing direct persistent volumes to network persistent volumes](architecture.png)

## Installation and Upgrades

 - [Install DirectPV]({{< relref "/installation/_index.md" >}})
 - [Upgrade DirectPV]({{< relref "/installation/upgrade.md" >}})

## Concepts

- [Architecture]({{< relref "concepts/architecture.md" >}})
- [Metrics and Monitoring]({{< relref "concepts/metrics.md" >}})
- [DirectPV Specification]({{< relref "concepts/specification.md" >}}) 

## Managing Resources

- [Resource Types]({{< relref "resource-management/_index.md" >}})
- [Drives]({{< relref "resource-management/drives.md" >}})
- [Nodes]({{< relref "resource-management/nodes.md" >}})
- [Volumes]({{< relref "resource-management/volumes.md" >}})
- [Schedule volumes by labels]({{< relref "resource-management/schedule-by-label.md" >}})
- [Schedule volumes]({{< relref "resource-management/scheduling.md" >}})
- [Useful Scripts]({{< relref "resource-management/scripts.md" >}})
 
## Frequently Asked Questions

- [Frequently Asked Questions]({{< relref "support/_index.md" >}})
- [Troubleshooting]({{< relref "support/troubleshooting.md" >}})

## Command Line Interface (CLI)

 - [CLI reference]({{< relref "command-line/_index.md" >}})

<!--- 
 - [Usage Guide](./usage-guide)
 - [Upgrades](./cli/upgrades) 
 
### Advanced
 - [Internals](./internals)
-->

## External References

- [MinIO Object Store Documentation](https://docs.min.io/community/minio-object-store?jmp=docs-directpv) 
- [Kubernetes CSI](https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/)
