---
title: move
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Description

Move volumes from one drive to another drive within a node (excluding data)

## Syntax

```sh
kubectl directpv move SRC-DRIVE DEST-DRIVE [flags]
```

### Aliases

You can use the following command to perform the same functions as `kubectl directpv move`

- `kubectl directpv mv`

This alias has the same results and use the same flags as `move`.

## Parameters

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--kubeconfig` \<string\> | Path to the `kube.config` file to use for CLI requests |
| `--quiet`                 | Suppress printing error messages                       |

## Example

### Move volumes from one drive to another

The following command moves volumes from one drive specified by Drive ID to another drive specified by Drive ID.

```sh {.copy}
kubectl directpv drives move af3b8b4c-73b4-4a74-84b7-1ec30492a6f0 834e8f4c-14f4-49b9-9b77-e8ac854108d5
```