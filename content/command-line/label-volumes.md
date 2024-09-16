---
title: label volumes
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Description

Set labels on the volumes managed by DirectPV

## Syntax

```sh
directpv label volumes key=value|key- [flags]
```

- Use `key=value` to add a custom label `key` with the value of `value` to the volume(s).
- Use `key-` to remove the custom label `key` from the volume(s).

  Only *custom* labels can be removed.
  Default labels used by DirectPV cannot be removed from the volume.

### Aliases

You can use the following commands to perform the same functions as `kubectl directpv label volumes`

- `kubectl directpv label volume`
- `kubectl directpv label vol`

These aliases have the same results and use the same flags as `label volumes`.

## Parameters

### Flags

| **Flag**                      | **Description**                                                                                              |
|-------------------------------|--------------------------------------------------------------------------------------------------------------|
| `--drive-id` \<string\>       | Modify labels on volumes on a specific drive ID.                                                             |
| `--pod-names` \<string\>      | Modify labels for volumes on specific pod names. You can use ellipsis pattern such as `minio-{0...4}`.       |
| `--pod-namespaces` \<string\> | Modify labels for volumes on specific pod namespaces. You can use ellipsis pattern such as `tenant-{0...3}`. |
| `--status` \<string\>         | Modify labels for volumes in a specific status. Valid statuses are `pending` or `ready`.                     |
| `--labels` \<string\>         | Modify labels on volumes with the specified labels. Include multiple labels as comma separated `key=value` pairs, such as `tier=hot,region=east`. You can only modify custom labels, not default DirectPV labels. |
| `--ids` \<string\>            | Modify labels for a specific volume ID.                                                                      |

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

### Add a label to all volumes in all nodes
   
The following command adds a label called `tier` with a value of `hot` on all volumes on all nodes.

```sh {.copy}
kubectl directpv label volumes tier=hot --all
```

### Set a label on volumes allocated in specific drives from a node

The following command adds a label called `type` with a value of `fast` on the drives `nvme1n1`, `nvme1n2`, and `nvme1n3` on the node `node1`.
The command uses ellipsis expansion notation to select the three drives.

```sh {.copy}
kubectl directpv label volumes type=fast --nodes=node1 --drives=nvme1n{1...3}
```

### Remove a label from all volumes in all nodes

The following command removes the label `tier` from all volumes, no matter what the value of `tier` might be on any volume.

```sh {.copy}
kubectl directpv label volumes tier- --all
```

You can only remove custom labels.
Default DirectPV labels cannot be removed.