---
title: Manage Nodes
date: 2023-07-26
lastmod: :git
draft: false
tableOfContents: true
weight: 10
---

## Prerequisites
* Working DirectPV plugin
 
  To install the plugin, refer to the [plugin installation guide]({{< relref "/installation/_index.md#plugin-installation" >}}).
* Working DirectPV CSI driver in Kubernetes

  To install the driver, refer to the [driver installation guide]({{< relref "/installation/_index.md#driver-installation" >}}

## Add node

Add a node to the DirectPV DaemonSet, then run the [`discover`]({{< relref "/command-line/discover.md" >}}) command. 

```sh
$ kubectl directpv discover
```

{{< admonition type="note" >}}
Drives from the added node are not available for DirectPV to use until you initialize them with the [`init`]({{< relref "/command-line/init.md" >}}) command.
{{< /admonition >}}

## List node

Use the [`info`]({{< relref "/command-line/info.md" >}}) command to list nodes. 

```sh
$ kubectl directpv info
┌──────────┬──────────┬───────────┬─────────┬────────┐
│ NODE     │ CAPACITY │ ALLOCATED │ VOLUMES │ DRIVES │
├──────────┼──────────┼───────────┼─────────┼────────┤
│ • master │ 512 MiB  │ 32 MiB    │ 2       │ 1      │
│ • node1  │ 512 MiB  │ 32 MiB    │ 2       │ 1      │
└──────────┴──────────┴───────────┴─────────┴────────┘

64 MiB/1.0 GiB used, 4 volumes, 2 drives

```

## Delete node
***CAUTION: THIS IS DANGEROUS OPERATION WHICH LEADS TO DATA LOSS***

Before removing a node make sure no volumes or drives on the node are in use, then remove the node from DirectPV DaemonSet and run [remove-node.sh](./tools/remove-node.sh) script.