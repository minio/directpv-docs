---
title: init
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Description

Initializing the drives 

- formats the selected drive(s) with XFS filesystem 
- mounts the drive(s) to `/var/lib/directpv/mnt/<UUID>`. 
  
DirectPV uses initialized drives to provision Persistent Volumes in response to Persistent Volume Claims with the `directpv-min-io` storage class.


{{< admonition title="Irrevocable Data Loss" type="warning" >}}
This command completely and irreversibly erases any data that may exist on the selected drive(s).
{{< /admonition >}}


## Syntax

```sh
kubectl directpv init drives.yaml [flags]
```

## Parameters

### Flags

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--timeout` \<duration\>  | Timeout for the initialization process (default 2m0s)  |

### Global Flags

You can use the following global DirectPV flags with `kubectl directpv init`:

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--kubeconfig` \<string\> | Path to the `kube.config` file to use for CLI requests |
| `--quiet`                 | Suppress printing error messages                       |

## Example

### Initialize the drives selected in `drives.yaml`

The following command initializes all the drives selected in the file `drives.yaml`.

```sh {.copy}
kubectl directpv init drives.yaml
```