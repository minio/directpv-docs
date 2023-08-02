---
title: uncordon
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Description

Uncordon drives to make them available for DirectPV to schedule.

## Syntax

```sh
kubectl directpv uncordon [DRIVE ...] [flags]
```

## Parameters

### Flags

| **Flag**                    | **Description**                                                                                             |
|-----------------------------|-------------------------------------------------------------------------------------------------------------|
| `--all` | Select all drives |
| `-d`, `--drives` \<string\> | Select drives by given names. Optionally, supports ellipsis expansion pattern, such as `sd{a...z}`. |
| `--dry-run` | Do a test run of the command without making any actual changes. |
| `-n`, `--nodes` \<string\> | Select drives from given nodes. Optionally, supports ellipsis expansion pattern, such as `node{1...10}`. |
| `--status` \<string\> | Select drives by status. Valid statuses include `error`, `lost`, `moving`, `ready`, or `removed`. |

### Global Flags

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--kubeconfig` \<string\> | Path to the `kube.config` file to use for CLI requests |
| `--quiet`                 | Suppress printing error messages                       |

## Examples

### Uncordon all drives from all nodes

The following command marks all cordoned drives in the cluster as available for scheduling.

```sh {.copy}
kubectl directpv uncordon --all
```

### Uncordon all drives from a node

The following command selects all cordoned drives on `node1` and makes them available for scheduling.

```sh {.copy}
kubectl directpv uncordon --nodes=node1
```

### Uncordon a drive from all nodes by drive name

The following command selects all drives named `nvme1n1` from all nodes and marks them and available for scheduling.

```sh {.copy}
kubectl directpv uncordon --drives=nvme1n1
```

### Uncordon specific drives from specific nodes

The following commmand selects drives `sda`, `sdb`, `sdc`, `sdd`, `sde`, and `sdf` on nodes `node1`, `node2`, `node3`, or `node4` and marks them as available for scheduling.
The command makes use of ellipsis expansion notation.

```sh {.copy}
kubectl directpv uncordon --nodes=node{1...4} --drives=sd{a...f}
```

### Uncordon drives which are in 'error' status

The following command selects drives in `error` status and makes them available for scheduling.

```sh {.copy}
kubectl directpv uncordon --status=error
```
