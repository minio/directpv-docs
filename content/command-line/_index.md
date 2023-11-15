---
title: DirectPV CLI
date: 2023-05-17
lastmod: :git
draft: false
heading: true
tableOfContents: true
weight: 90
---

DirectPV provides a `kubectl` plugin for managing DirectPV drives and volumes.
Use this plugin at the command line to complete all of the functions required for adding, managing, scheduling, and removing DirectPV drives and volumes in a Kubernetes cluster.

## Install Kubectl plugin

The `directpv` kubectl plugin can be used to manage the lifecycle of volumes and drives in a Kubernetes cluster.

Run the following command to install the DirectPV plugin:

```sh {.copy}
kubectl krew install directpv
```

{{< admonition type="note">}}
For more complete instructions on installing DirectPV, including installing with a binary instead of using `krew`, see the [installation page]({{< relref "installation/_index.md" >}}).
{{< /admonition>}}

## Usage

If installed with `krew`, use

```sh
kubectl directpv [command] [flags]
```

If installed as a binary, use

```sh
kubectl-directpv [command] [flags]
```

## Flags

The following flags are available for `kubectl directpv` and many of the commands included with the plugin.

| **Flag**              | **Description**                                     |
|-----------------------|-----------------------------------------------------|
| `-h`, `--help`        | help for directpv                                   |
| `--kubeconfig string` | Path to the kubeconfig file to use for CLI requests |
| `--quiet`             | Suppress printing error messages                    |
| `--version`           | version for directpv                                |

## Available Commands

This documentation includes details for each available command on separate subpages.
The available commands include:

| **Command**                             | **Description**                                                   |
|-----------------------------------------|-------------------------------------------------------------------|
| *Install*                               |                                                                   |
| [`install`](install.md)                 | Install DirectPV in Kubernetes                                    |
| *Manage Drives and Volumes*             |                                                                   |
| [`discover`](discover.md)               | Discover new drives                                               |
| [`info`](info.md)                       | Show information about DirectPV installation                      |
| [`init`](init.md)                       | Initialize drives                                                 |
| [`label drives`](label-drives.md)       | Set labels to drives                                              |
| [`label volumes`](label-volumes.md)     | Set labels to volumes                                             |
| [`list-drives`](list-drives.md)         | List drives                                                       |
| [`list-volumes`](list-volumes.md)       | List volumes                                                      |
| [`resume-drives`](resume-drives.md)     | Resume suspended drives                                           |
| [`resume-volumes`](resume-volumes.md)   | Resume suspended volumes                                          |
| [`suspend-drives`](suspend-drives.md)   | Suspend drives                                                    |
| [`suspend-volumes`](suspend-volumes.md) | Suspend volumes                                                   |
| *Manage Scheduling*                     |                                                                   |
| [`cordon`](cordon.md)                   | Mark drives as unschedulable                                      |
| [`uncordon`](uncordon.md)               | Mark drives as schedulable                                        |
| *Maintenance*                           |                                                                   |
| [`clean`](clean.md)                     | Cleanup stale volumes                                             |
| [`migrate`](migrate.md)                 | Migrate drives and volumes from legacy DirectCSI                  |
| [`move`](move.md)                       | Move volumes excluding data from source drive to destination drive on a same node |
| [`remove`](remove.md)                   | Remove unused drives from DirectPV                                |
| *Uninstall DirectPV*                    |                                                                   |
| [`uninstall`](uninstall.md)             | Uninstall DirectPV in Kubernetes                                  |

## Command History

### DirectPV Command changes

| Old DirectPV Command        | Replacement DirectPV Command       |
|:----------------------------|:-----------------------------------|
| `kubectl directpv discover` | [`kubectl directpv init`](init.md) |

### Command changes from DirectCSI

| DirectCSI Command                | DirectPV Command                                          |
|:---------------------------------|:----------------------------------------------------------|
| `kubectl directcsi drives list`  | `kubectl directpv list drives`                            |
| `kubectl directcsi volumes list` | `kubectl directpv list volumes`                           |
| `kubectl directcsi format`       | `kubectl directpv discover`, then `kubectl directpv init` |