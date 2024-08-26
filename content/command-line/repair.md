---
title: repair
date: 2024-08-26
lastmod: :git
draft: false
tableOfContents: true
---

## Description

{{< admonition title="Irrevocable Data Loss" type="warning" >}}
This command completely and irreversibly erases any data that may exist on the selected drive(s).
{{< /admonition >}}

In a rare situation, the filesystem on a faulty XFS-formatted drive can be repaired to make them usable. 

The `repair` command creates one-time Kubernetes `Job` with the pod name as `repair-<DRIVE-ID>`.
Kubernetes automatically removes this job five minutes after completion.

Progress and status of the drive repair can be viewed using `kubectl log` command. 

Before beginning a repair, you must first [suspend the drive]({{< relref "/command-line/suspend-drives.md" >}}).

To retrieve the ID of the drive to repair, use [list drives]({{< relref "/command-line/list-drives.md" >}})

## Syntax

```sh
kubectl directpv repair DRIVE [flags]
```

## Parameters

### Flags

| **Flag**                  | **Description**                                                         |
|---------------------------|-------------------------------------------------------------------------|
| `--dry-run`               | See the output of the command without actually changing any drives.     |
| `--force`                 | Force log zeroing.                                                      |
| `--disable-prefetch`      | Disable prefetching of inode and directory blocks.                      |

### Global Flags

You can use the following global DirectPV flags with `kubectl directpv init`:

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--kubeconfig` \<string\> | Path to the `kube.config` file to use for CLI requests |
| `--quiet`                 | Suppress printing error messages                       |

## Example

### Repair a drive

The following begins a repair operation on the specified drive.

```sh {.copy}
kubectl directpv repair 3b562992-f752-4a41-8be4-4e688ae8cd4c
```