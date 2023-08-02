---
title: remove
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Description

Remove unused drives from DirectPV.

## Syntax

```sh
directpv remove [DRIVE ...] [flags]
```

## Parameters

### Flags

| **Flag**                    | **Description**                                                                                     |
|-----------------------------|-----------------------------------------------------------------------------------------------------|
| `--dry-run`                 | See the results of the command without making any actual changes to drives.                         |
| `-n`, `--nodes` \<string\>  | Select drives from specified node(s). Use ellipsis expansion notation, such as `node{1...10}`.      |
| `-d`, `--drives` \<string\> | Select drives by given names. Use ellipsis expansion notation, such as `sd{a...z}`.                 |
| `--status` \<string\>       | Select drives by drive status. Valid statuses are `error`, `lost`, `moving`, `ready`, or `removed`. |
| `--all`                     |             If present, select all unused drives

### Global Flags

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--kubeconfig` \<string\> | Path to the `kube.config` file to use for CLI requests |
| `--quiet`                 | Suppress printing error messages                       |

## Examples

### Remove an unused drive from all nodes

The following command removes a drive named `nvme1n1` found on any node.

```sh {.copy}
kubectl directpv remove --drives=nvme1n1
```

### Remove all unused drives from a node

The following command removes all unused drives from the node `node1`. 

```sh {.copy}
kubectl directpv remove --nodes=node1
```

### Remove specific unused drives from specific nodes

The following command removes drives `sda` through `sdf` on `node1`, `node2`, `node3`, and `node4`.
The command uses ellipsis expansion notation select both the nodes and the drives.

```sh {.copy}
kubectl directpv remove --nodes=node{1...4} --drives=sd{a...f}
```

### Remove all unused drives from all nodes

The following command removes all unused drives across all nodes from DirectPV.

```sh {.copy}
kubectl directpv remove --all
```

### Remove drives that are in a specific status

The following command removes any drive in the status of `error` on any node.

```sh {.copy}
kubectl directpv remove --status=error
```
