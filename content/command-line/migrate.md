---
title: migrate
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Description

Migrate drives and volumes from legacy DirectCSI to DirectPV.

## Syntax

```sh
directpv migrate [flags]
```

## Parameters

### Flags

| **Flag**    | **Description**                                                                        |
|-------------|----------------------------------------------------------------------------------------|
| `--dry-run` | See the results of the command without making any actual changes to drives or volumes. |

### Global Flags

You can use the following global DirectPV flags with `kubectl directpv migrate`:

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--kubeconfig` \<string\> | Path to the `kube.config` file to use for CLI requests |
| `--quiet`                 | Suppress printing error messages                       |

## Example

### Migrate drives and volumes from legacy DirectCSI

The following command migrates any drives and volumes created under DirectCSI for management by DirectPV instead.

```sh {.copy}
kubectl directpv migrate
```