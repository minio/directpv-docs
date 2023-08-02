---
title: OpenShift
date: 2023-00-07
lastmod: :git
draft: false
tableOfContents: true
---

Red Hat OpenShift has unique requirements.
Use this page for information on required setups and expected limitations when running DirectPV on OpenShift.

## Required Settings

* Create new project 
  
  For example, the following command creates a a new project called `my-directpv-installation` with a display name of `DirectPV`.

  ```sh {.copy}
  oc new-project my-directpv-installation --description="My DirectPV installation for local volume provisioning" --display-name="DirectPV"
  ```

* Add privileges to the `directpv` namespace and DirectPV service account by adding `system:serviceaccount:directpv:directpv-min-io` to users
  
  ```sh {.copy}
  oc edit scc privileged
  ```

## Limitations

* DirectPV does not support the volume snapshot feature as described in the [Container Storage Interface (CSI) specification](https://github.com/container-storage-interface/spec.

  DirectPV is specifically meant for use cases like MinIO where the data availability and resiliency is taken care by the application itself. 
  Additionally, with the AWS S3 versioning APIs and internal healing, snapshots are not a requirement.

* DirectPV does not support `ReadWriteMany` volume access mode. 

  The workloads using DirectPV run local to the node and are provisioned from local storage drives in the node. 
  This allows the workloads to directly access data without any additional network hops, unlike remote volumes, network PVs, etc. 
  The additional network hops may lead to poor performance and increases the complexity. 
  With `ReadWriteOnce` access mode, DirectPV provides high performance storage for Pods.