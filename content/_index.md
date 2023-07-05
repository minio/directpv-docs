---
title: MinIO DirectPV
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

This set of pages describes DirectPV, a Container Storage Interface (CSI) for direct attached storage made by MinIO.

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

 - [Install DirectPV]({{< relref "/content/installation/_index.md" >}})
 - [Upgrade DirectPV]({{< relref "/content/installation/upgrade.md" >}})

## Concepts

- [Architecture]({{< relref "/content/concepts/architecture.md" >}})
- [Metrics and Monitoring]({{< relref "/content/concepts/metrics.md" >}})
- [DirectPV Specification]({{< relref "/content/concepts/specification.md" >}}) 

## Managing drives

- [Replace Drives]({{< relref "/content/manage-drives/drive-replacement.md" >}})
- [Remove Nodes]({{< relref "/content/manage-drives/drain-node.md" >}})
- [Expand Volumes]({{< relref "/content/manage-drives/volume-expansion.md" >}})
 
## Volume Scheduling

- [Scheduling Overview]({{< relref "/content/volume-scheduling/_index.md" >}})
- [Schedule PVCs]({{< relref "/content/volume-scheduling/scheduling.md" >}})

## Frequently Asked Questions

- [Frequently Asked Questions]({{< relref "/content/faqs/_index.md" >}})
- [Troubleshooting]({{< relref "/content/faqs/troubleshooting.md" >}})

## Command Line Interface (CLI)

 - [CLI reference]({{< relref "content/command-line/_index.md" >}})

<!--- 
 - [Usage Guide](./usage-guide.md)
 - [Upgrades](./cli/upgrades.md) 
 
### Advanced
 - [Internals](./internals.md)
-->

## External References

- [MinIO Documentation](https://min.io/docs/minio/kubernetes/upstream/index.html?ref=DirectPV-Docs) 
- [Kubernetes CSI](https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/)
