---
title: resume drives
date: 2023-11-15
lastmod: :git
draft: false
tableOfContents: true
---

## Description

Resume suspended drives.

## Syntax

```sh
directpv resume drives [DRIVE ...] [flags]
```

## Parameters

### Flags

| **Flag**                    | **Description**                                                                                     |
|-----------------------------|-----------------------------------------------------------------------------------------------------|
| `-n`, `--nodes` \<string\>  | Resume drives from specified node(s). Use ellipsis expansion notation, such as `node{1...10}`.      |
| `-d`, `--drives` \<string\> | Resume drives by given names. Use ellipsis expansion notation, such as `sd{a...z}`.                 |
| `--dry-run`                 | See the results of the command without making any actual changes to drives.                         |

### Global Flags

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--kubeconfig` \<string\> | Path to the `kube.config` file to use for CLI requests |
| `--quiet`                 | Suppress printing error messages                       |

## Examples

### Resume all suspended drives from a node

```sh {.copy}
kubectl directpv resume drives --nodes=node1
```

### Resume specific drive from specific node

```sh {.copy}
kubectl directpv resume drives --nodes=node1 --drives=sda
```

### Resume a suspended drive by DRIVE-ID

```sh {.copy}
kubectl directpv resume drives af3b8b4c-73b4-4a74-84b7-1ec30492a6f0
```