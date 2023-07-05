---
title: cordon
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Description

Cordoning drives makes them unschedulable.
DirectPV does not schedule volumes on drives that have been cordoned.

Use [`kubectl directpv uncordon`]({{< relref "command-line/uncordon.md" >}}) to make cordoned drives accessible for scheduling again.

## Syntax

```sh
kubectl directpv cordon [DRIVE ...] [flags]
```

## Parameters

`kubectl directpv cordon` requires a way to define the drive(s) to cordon.
The command does not require any specific parameter.
All parameters are optional, as long as you include a way to select one or more drives in the command.

### Flags

| **Flag**                    | **Description**                                                                                             |
|-----------------------------|-------------------------------------------------------------------------------------------------------------|
| `--all`                     | Select all drives. |
| `-d`, `--drives` \<string\> | Select drives by given names. Optionally, supports ellipsis expansion pattern, such as `sd{a...z}`. |
| `--dry-run`                 | Run a trial of the command without making changes to the drive(s). |
| `-n`, `--nodes` \<string\>  | Select drives from the specified notes nodes. Optionally, supports ellipsis expansion pattern, such as `node{1...10}`. |
| `--status` \<string\>       | Select drives by drive status. Valid statuses include: `error`, `lost`, `moving`, `ready`, or `removed`. |

### Global Flags

You can use the following global DirectPV flags with `kubectl directpv cordon`:

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--kubeconfig` \<string\> | Path to the `kube.config` file to use for CLI requests |
| `--quiet`                 | Suppress printing error messages                       |

## Examples

### Cordon all drives from all nodes
   
The following command cordons all drives from all nodes.

```sh {.copy}   
kubectl directpv cordon --all
```

### Cordon all drives from a node

The following command cordons all drives from the specified node(s).
This command uses a flag that supports ellipsis expansion notation pattern.

```sh {.copy}
kubectl directpv cordon --nodes=node1
```

### Cordon a drive from all nodes by name

The following command cordons a the drive named `nvme1n1` drive from all nodes.

```sh {.copy}
kubectl directpv cordon --drives=nvme1n1
```

### Cordon specific drives from specific nodes with expansion notation

The following command cordons drives `sda`, `sdb`, `sdc`, `sdd`, `sde`, and `sdf` from nodes `node1`, `node2`, `node3`, and `node4`.

```sh {.copy}
kubectl directpv cordon --nodes=node{1...4} --drives=sd{a...f}
```

### Cordon drives which are in 'error' status
   
The following command cordons all drives with the status of `error`.

```sh {.copy}
kubectl directpv cordon --status=error
```
