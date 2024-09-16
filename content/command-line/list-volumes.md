---
title: list volumes
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Description

List the volumes provisioned and managed by DirectPV.

## Syntax

```sh
kubectl directpv list volumes [VOLUME ...] [flags]
```

You can use the following commands to perform the same functions as `kubectl directpv list volumes`

- `kubectl directpv list volume`
- `kubectl directpv list vol`

These aliases have the same results and use the same flags as `list volumes`.

## Parameters

### Flags

| **Flag**                       | **Description**                                                                                  |
|--------------------------------|--------------------------------------------------------------------------------------------------|
| `--drive-id` \<string\>        | Filter output by drive IDs                                                                       |
| `--pod-names` \<string\>       | Filter output by pod names; supports ellipses pattern such as `minio-{0...4}`                    |
| `--pod-namespaces` \<string\>  | Filter output by pod namespaces; supports ellipses pattern such as `tenant-{0...3}`              |
| `--pvc`                        | Add Persistent Volume Claim (PVC) names in the output                                            |
| `--status` \<string\>          | Filter output by volume status. Valid statuses are `pending` or `ready`.                         |
| `--show-labels`                | Show all custom labels as the last column                                                        |
| `--labels` \<string\>          | Filter output by volume labels. Enter labels as key-value pairs, such as, `tier=hot,region=east` |
| `--all`                        | List all volumes                                                                                 |

### Global Flags

You can use the following global DirectPV flags with `kubectl directpv list-volumes`:

| **Flag**                    | **Description**                                                             |
|-----------------------------|-----------------------------------------------------------------------------|
| `-d`, `--drives` \<string\> | Filter output by drive names; supports ellipses pattern such as `sd{a...z}` |
| `--kubeconfig` \<string\>   | Path to the kubeconfig file to use for CLI requests                         |
| `-n`, `--nodes` \<string\>  | Filter output by nodes; supports ellipses pattern such as `node{1...10}`    |
| `--no-headers`              | Don't print column headers                                                  |
| `-o`, `--output` \<string\> | Output format. Valid options are `json`, `yaml`, `wide`                     |
| `--quiet`                   | Suppress printing error messages                                            |

## Examples

### List all ready volumes

The following command lists all volumes in `ready` status.
DirectPV can schedule these volumes to a matching PVC.

```sh {.copy}
kubectl directpv list volumes
```

### List volumes served by a node

The following command lists all volumes for the node `node1`.

```sh {.copy}
kubectl directpv list volumes --nodes=node1
```

### List volumes served by drives on nodes

The following command lists all volumes served from the drive `nvme0n1` on either `node1` or `node2`.

```sh {.copy}
kubectl directpv list volumes --nodes=node1,node2 --drives=nvme0n1
```

### List volumes by pod name

The following command lists all volumes for the pods `minio-1`, `minio-2`, and `minio-3`.
The command uses ellipsis expansion notation for the pod name list.

```sh {.copy}
kubectl directpv list volumes --pod-names=minio-{1...3}
```

### List volumes by pod namespace
   
The following lists all volumes for the pods in the namespaces `tenant-1`, `tenant-2`, and `tenant-3`.
The command uses ellipsis expansion notation for the namespace list.

```sh {.copy}   
kubectl directpv list volumes --pod-namespaces=tenant-{1...3}
```

### List all volumes from all nodes with all information, including PVC name

The following command lists all volumes and includes all available information for all volumes.

```sh {.copy}
kubectl directpv list volumes --all --pvc --output wide
```

### List volumes in Pending state
   
The following command lists volumes in the `pending` status.

```sh {.copy}   
kubectl directpv list volumes --status=pending
```

### List volumes served by a drive ID

The following command lists all volumes on the drive specified by its ID.

```sh {.copy}
kubectl directpv list volumes --drive-id=b84758b0-866f-4a12-9d00-d8f7da76ceb3
```

### List volumes with labels

The following command lists all volumes and includes a column to show the custom labels assigned to each volume, if any.

```sh {.copy}
kubectl directpv list volumes --show-labels
```

### List volumes filtered by labels

The following command lists volumes with a label of `tier` where the value assigned to the label is `hot`.

```sh {.copy}
kubectl directpv list volumes --labels tier=hot
```