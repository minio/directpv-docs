---
title: suspend volumes
date: 2023-11-15
lastmod: :git
draft: false
tableOfContents: true
---

## Description

[Suspend volumes]({{< relref "/resource-management/volumes.md#suspend-volumes" >}}) and mark as read only.
Suspending volumes mounts a volume to an empty temporary directory, allowing a StatefulSet to start up.

To resume, use the [resume volumes]({{< relref "/command-line/resume-volumes.md" >}}) command.

## Syntax

```sh
  directpv suspend volumes [VOLUME ...] [flags]
```

## Parameters

### Flags

While all flags are optional, you must specify at least one drive by ID, name, or node.

| **Flag**             | **Description**                                                                                        |
|----------------------|--------------------------------------------------------------------------------------------------------|
| `--dangerous`        | Acknowledge that suspending volumes marks them read-only.                                              |
| [VOLUME]             | ID of a volume to suspend.                                                                             |
| [`-d, --drives`]     | Suspend volumes by given name(s). Supports ellipsis notation such as `sd{a...m}`.                      |
| [`-n, --nodes`]      | Suspend volumes from the given node(s). Supports ellipsis notation such as `node{1...10}`.             |
| [`--pod-names`]      | Suspend volumes from the given pod(s). Supports ellipsis notation such as `minio-{0...4}`.             |
| [`--pod-namespaces`] | Suspend volumes from the given namespace(s). Supports ellipsis notation such as `tenant-{0...3}`.      |
| [`--dry-run`]        | See the results of the command without making any actual changes to drives.                            |

### Global Flags

You can use the following global DirectPV flags with `kubectl directpv info`:

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--kubeconfig` \<string\> | Path to the `kube.config` file to use for CLI requests |
| `--quiet`                 | Suppress printing error messages                       |

## Examples

### Suspend all volumes for a node

```sh {.copy}
kubectl directpv suspend volumes --nodes=node1
```

### Suspend a specific volume from a specific node

```sh {.copy}
kubectl directpv suspend volumes --nodes=node1 --volumes=sda
```

### Suspend volume by ID

```sh {.copy}
kubectl directpv suspend volumes pvc-0700b8c7-85b2-4894-b83a-274484f220d0
```