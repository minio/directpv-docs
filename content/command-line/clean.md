---
title: clean
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Description

Cleans up volumes in either released or deleted status.

## Syntax

```sh
kubectl directpv clean [VOLUME ...] [flags]
```

## Parameters

`kubectl directpv clean` requires either a volume ID or a flag to define the volume(s) or drive(s) to clean.
The command does not require any specific parameter.
All parameters are optional, as long as you include a way to select one or more volumes in the command.

### Flags

| **Flag**                      | **Description**                                                                                             |
|-------------------------------|-------------------------------------------------------------------------------------------------------------|
| `--all`                       | Select all volumes.                                                                                         |
| `-d`, `--drives` \<string\>   | Select volumes by drive names. Optionally supports ellipsis expansion pattern, such as `sd{a...z}`.         |
| `--drive-id` \<string\>       | Select all volumes on a specific drive ID.                                                                  |
| `--dry-run`                   | Test the command to see what it would do without making any actual changes.                                 |
| `-n`, `--nodes` \<string\>    | Select volumes from given nodes. Optionally supports ellipsis expansion pattern, such as `node{1...10}`.    |
| `--pod-names` \<string\>      | Select volumes by pod names. Optionally supports ellipsis expansion pattern such as `minio-{0...4}`         |
| `--pod-namespaces` \<string\> | Select volumes by pod namespaces. Optionally supports ellipsis expansion pattern, such as `tenant-{0...3}`. |

### Global Flags

You can use the following global DirectPV flags with `kubectl directpv clean`:

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--kubeconfig` \<string\> | Path to the `kube.config` file to use for CLI requests |
| `--quiet`                 | Suppress printing error messages                       |

## Examples

### Clean up all stale volumes

The following command cleans all DirectPV volumes with a status of released or deleted.

```sh {.copy}
kubectl directpv clean --all
```

### Clean a volume by its ID

The following command cleans the specific volume with the ID `pvc-6355041d-f9c6-4bd6-9335-f2bccbe73929`.
To specify a volume, pass the volume's ID.
There is no flag for a volume ID.

```sh {.copy}
kubectl directpv clean pvc-6355041d-f9c6-4bd6-9335-f2bccbe73929
```

### Clean volumes on a drive by drive name

The following command cleans up volumes in deleted or released status on the drive with drive name `nvme1n1`.

```sh {.copy}   
kubectl directpv clean --drives=nvme1n1
```

### Clean volumes on a drive by drive ID

The following command cleans up volumes in deleted or released status on the drive with ID `78e6486e-22d2-4c93-99d0-00f4e3a8411f`.

```sh {.copy}
kubectl directpv clean --drive-id=78e6486e-22d2-4c93-99d0-00f4e3a8411f
```

### Clean volumes served by a node

The following command cleans up volumes in deleted or released status on node `node1`.
You can specify multiple nodes using ellipsis expansion notation.

```sh {.copy}
kubectl directpv clean --nodes=node1
```

### Clean volumes by pod name

The following command cleans up all volumes in deleted or released status on pods `minio-1`, `minio-2`, and `minio-3`.
The command uses ellipsis expansion notation to specify the three nodes.

```sh {.copy}
kubectl directpv clean --pod-names=minio-{1...3}
```

### Clean volumes by pod namespace

The following command cleans up all volumes in deleted or released status on pod namespaces `tenant-1`, `tenant-2`, and `tenant-3`.
The command uses ellipsis expansion notation to specify the three namespaces.

```sh {.copy}
kubectl directpv clean --pod-namespaces=tenant-{1...3}
```
