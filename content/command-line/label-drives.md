---
title: label drives
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Description

Set labels on the drives managed by DirectPV

## Syntax

```sh
directpv label drives key=value|key- [flags]
```

Use only one or the other of the options:
- Use `key=value` to add a custom label `key` with the value of `value` to the drive(s).
- Use `key-` to remove the custom label `key` from the drive(s).
  
  Only *custom* labels can be removed.
  Default labels used by DirectPV cannot be removed from the drive.


### Aliases

You can use the following commands to perform the same functions as `kubectl directpv label drives`

- `kubectl directpv label drive`
- `kubectl directpv label dr`

These aliases have the same results and use the same flags as `label drives`.

## Parameters

### Flags

| **Flag**              | **Description**                                                                                  |
|-----------------------|--------------------------------------------------------------------------------------------------|
| `--ids` \<string\>    | Select by drive ID                                                                               |
| `--labels` \<string\> | Select by drive labels; supports comma separated key=value pairs, such as `tier=hot,region=east` |
| `--status` \<string\> | Select drives by status. Valid statuses include `error`, `lost`, `moving`, `ready`, or `removed` |

### Global Flags

You can use the following global DirectPV flags with `kubectl directpv list`:

| **Flag**                    | **Description**                                                              |
|-----------------------------|------------------------------------------------------------------------------|
| `--all`                     | Select all drives                                                            |
| `-d`, `--drives` \<string\> | Filter output by drive names; supports ellipses pattern such as `sd{a...z}`  |
| `--dry-run`                 | Run the command and generate the output without making changes to any drives |
| `--kubeconfig` \<string\>   | Path to the kubeconfig file to use for CLI requests                          |
| `-n`, `--nodes` \<string\>  | Filter output by nodes; supports ellipses pattern such as `node{1...10}`     |
| `--quiet`                   | Suppress printing error messages                                             |

## Examples

### Set a label to all drives in all nodes

The following command sets a label called `tier` to a value of `hot` on all drives on all notes.

```sh {.copy}
kubectl directpv label drives tier=hot --all
```

### Set a label for specific drives from a node

The following command sets a label named `type` with a value of `fast` to specific drives on `node1`.
The command uses ellipsis notation for the drive names to select drives `nvme1n1`, `nvme1n2`, and `nvme1n3`.

```sh {.copy}
kubectl directpv label drives type=fast --nodes=node1 --drives=nvme1n{1...3}
```

### Remove a label from all drives in all nodes

The following command removes the label `tier` from all drives on all nodes.
The command removes the label no matter what the value of `tier` may be on each drive.

```sh {.copy}
kubectl directpv label drives tier- --all
```

You can only remove custom labels.
Default DirectPV labels cannot be removed.