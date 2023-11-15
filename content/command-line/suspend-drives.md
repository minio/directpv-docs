---
title: suspend drives
date: 2023-11-15
lastmod: :git
draft: false
tableOfContents: true
---

## Description

[Suspend drives]({{< relref "/resource-management/drives.md#suspend-drives" >}}) and mark any volumes on the drives as read only.
Suspending drives mounts a drive to an empty temporary directory, allowing a StatefulSet to start up.

To resume, use the [resume drives]({{< relref "/command-line/resume-drives.md" >}}) command.

## Syntax

```sh
  directpv suspend drives [DRIVE ...] [flags]
```

## Parameters

### Flags

While all flags are optional, you must specify at least one drive by ID, name, or node.

| **Flag**         | **Description**                                                                           |
|------------------|-------------------------------------------------------------------------------------------|
| `--dangerous`    | Acknowledge that suspending drives makes the corresponding volume(s) read-only.           |
| [DRIVE]          | ID of a drive to suspend.                                                                 |
| [`-d, --drives`] | Suspend drives by given name(s). Supports ellipsis notation such as `sd{a...m}`.          |
| [`-n, --nodes`]  | Suspend drives from the given node(s). Supports ellipsis notation such as `node{1...10}`. |
| [`--dry-run`]    | See the results of the command without making any actual changes to drives.               |

### Global Flags

You can use the following global DirectPV flags with `kubectl directpv info`:

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--kubeconfig` \<string\> | Path to the `kube.config` file to use for CLI requests |
| `--quiet`                 | Suppress printing error messages                       |

## Examples

### Suspend all drives for a node

```sh {.copy}
kubectl directpv suspend drives --nodes=node1
```

### Suspend a specific drive from a specific node

```sh {.copy}
kubectl directpv suspend drives --nodes=node1 --drives=sda
```

### Suspend drive by ID

```sh {.copy}
kubectl directpv suspend drives af3b8b4c-73b4-4a74-84b7-1ec30492a6f0
```