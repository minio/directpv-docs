---
title: resume volumes
date: 2023-11-15
lastmod: :git
draft: false
tableOfContents: true
---

## Description

Resume suspended volumes.

## Syntax

```sh
directpv resume volumes [VOLUME ...] [flags]
```

## Parameters

### Flags

| **Flag**                      | **Description**                                                                                  |
|-------------------------------|--------------------------------------------------------------------------------------------------|
| `-n`, `--nodes` \<string\>    | Resume volumes from specified node(s). Use ellipsis expansion notation, such as `node{1...10}`.  |
| `-d`, `--drives` \<string\>   | Resume volumes by given names. Use ellipsis expansion notation, such as `sd{a...z}`.             |
| `--pod-names` \<string\>      | Resume volumes by given pod(s). Use ellipsis expansion notation, such as `minio-{0...4}`.        |
| `--pod-namespaces` \<string\> | Resume volumes by given namespace(s). Use ellipsis expansion notation, such as `tenant-{0...3}`. |
| `--dry-run`                 | See the results of the command without making any actual changes to drives.                        |

### Global Flags

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--kubeconfig` \<string\> | Path to the `kube.config` file to use for CLI requests |
| `--quiet`                 | Suppress printing error messages                       |

## Examples

### Resume all volumes from a node

```sh {.copy}
kubectl directpv resume volumes --nodes=node1
```

### Resume specific volume from specific node

```sh {.copy}
kubectl directpv resume volumes --nodes=node1 --volumes=sda
```

### Resume a volume by name

```sh {.copy}
kubectl directpv resume volumes pvc-0700b8c7-85b2-4894-b83a-274484f220d0
```