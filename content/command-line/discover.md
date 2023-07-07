---
title: discover
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Description

Use this command to discover the block devices present in the cluster.
The command outputs a yaml file listing the available drives.

After generating the yaml, modify the file to select the drive(s) you wish to use with DirectPV.
Ensure that any drives that should not be erased by DirectPV have **not** been selected in the yaml file.

After discovering the drives, use the [`kubectl directpv init`]({{< relref "/command-line/init.md" >}}) command to initialize the drives for use with DirectPV.

## Syntax

```sh
kubectl directpv discover [flags]
```

## Parameters

### Flags

| **Flag** | **Description** |
|----------|-----------------|
| `-n`, `--nodes` \<string\> | Discover drives from given nodes. Optionally supports ellipsis expansion notation, such as `node{1...10}`. |
| `-d`, `--drives` \<string\> | Discover drives by given names. Optionally supports ellipses expansion notation, such as `sd{a...z}`. |
| `--all` | Include all non-formattable devices in the display. |
| `--output-file` \<string\> | Path and name of the output file to write the init config (defaults to `drives.yaml`). |
| `--timeout` \<duration\> | Specify a timeout for the discovery process (default `2m0s`). |

### Global Flags

You can use the following global DirectPV flags with `kubectl directpv discover`:

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--kubeconfig` \<string\> | Path to the `kube.config` file to use for CLI requests |
| `--quiet`                 | Suppress printing error messages                       |

## Examples

## Discover drives on the cluster

Use the following command to discover all drives throughout the cluster.

```sh {.copy}
kubectl directpv discover
```

### Discover drives from a node

Use the following command to discover drives on the specific node, `node1`.

```sh {.copy}   
kubectl directpv discover --nodes=node1
```

### Discover a drive from all nodes

The following command discovers the drive named `nvme1n1` on any node where it can be found.

```sh {.copy}
kubectl directpv discover --drives=nvme1n1
```

### Discover all drives from all nodes (including unavailable)
   
The following command discovers all drives on all nodes on the cluster, including any drive that DirectPV would not be able to format for use.

```sh {.copy}
kubectl directpv discover --all
```

### Discover specific drives from specific nodes

The following command uses ellipsis expansion notation to find specific drives on a specific set of nodes.

```sh {.copy}
kubectl directpv discover --nodes=node{1...4} --drives=sd{a...f}
```
