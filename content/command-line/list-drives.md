---
title: list drives
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Description

List the drives initialized and managed by DirectPV.

## Syntax

```sh
directpv list drives [DRIVE ...] [flags]
```

### Aliases

You can use the following commands to perform the same functions as `kubectl directpv list drives`

- `kubectl directpv list drive`
- `kubectl directpv list dr`

These aliases have the same results and use the same flags as `list drives`.

## Parameters

### Flags

| **Flag**              | **Description**                                                                                        |
|-----------------------|--------------------------------------------------------------------------------------------------------|
| `--all`               | List all drives                                                                                        |
| `--labels` \<string\> | Filter output by drive labels. Supports comma-separated key=value pairs such as `tier=hot,region=east` |
| `--show-labels`       | Show all labels as the last column of the output (default hide labels column)                          |
| `--status` \<string\> | Filter output by drive status. Valid statuses are `error`, `lost`, `moving`, `ready`, or `removed`     |

### Global Flags

You can use the following global DirectPV flags with `kubectl directpv list`:

| **Flag**                    | **Description**                                                             |
|-----------------------------|-----------------------------------------------------------------------------|
| `-d`, `--drives` \<string\> | Filter output by drive names; supports ellipses pattern such as `sd{a...z}` |
| `--kubeconfig` \<string\>   | Path to the kubeconfig file to use for CLI requests                         |
| `-n`, `--nodes` \<string\>  | Filter output by nodes; supports ellipses pattern such as `node{1...10}`    |
| `--no-headers`              | Don't print column headers                                                  |
| `-o`, `--output` \<string\> | Output format. Valid options are `json`, `yaml`, `wide`                     |
| `--quiet`                   | Suppress printing error messages                                            |

## Examples

### List all ready drives

The following command lists all drives that are in a `ready` state.

```sh {.copy}
kubectl directpv list drives
```

### List all drives from a node

The following command lists all drives on `node1`.

```sh {.copy}
kubectl directpv list drives --nodes=node1
```

### List a drive from all nodes

The following command lists the drive `nvme1n1` from any node.

```sh {.copy}
kubectl directpv list drives --drives=nvme1n1
```

### List specific drives from specific nodes

The following command lists drives `sda` through `sdf` for `node` through `node4`.

```sh {.copy}
kubectl directpv list drives --nodes=node{1...4} --drives=sd{a...f}
```

### List drives are in 'error' status

The following command lists all drives that are currently in `error` status from any node.

```sh {.copy}
kubectl directpv list drives --status=error
```

### List all drives from all nodes with all information

The following command lists drives in `ready` status from all nodes with all available information.

```sh {.copy}
kubectl directpv list drives --output wide
```

### List drives with labels

The following lists drives and includes a column that shows drive labels.

```sh {.copy}
kubectl directpv list drives --show-labels
```

### List drives filtered by labels

The following command lists all drives in `ready` status on any node that have the label `tier=hot`.

```sh {.copy}
kubectl directpv list drives --labels tier=hot
```
