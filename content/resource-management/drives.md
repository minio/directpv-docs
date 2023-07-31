---
title: Managing Drives
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: false
weight: 20
---

## Prerequisites

* Working DirectPV plugin. 
 
  To install the plugin, refer to the [plugin installation guide]({{< relref "installation/_index.md#plugin-installation" >}}).

* Working DirectPV CSI driver in Kubernetes. 
 
  To install the driver, refer to the [driver installation guide]({{< relref "installation/_index.md#driver-installation" >}}).

## Drives

### Add drives

DirectPV must have access to drives to provision volumes. 
This involves a two step process.

1. Run the [`discover`]({{< relref "command-line/discover.md" >}}) command.
   
   The `discover` command probes for eligible drives from DirectPV nodes and stores drive information in a YAML file. 
   You should carefully examine the YAML file and set the `select` field to `yes` or `no` value to indicate drive selection. 
   
   The `select` field is set to `yes` value by default for all discovered drives. 
   
   Below is an example of the `discover` command:
   
   ```sh
   # Probe and save drive information to drives.yaml file.
   $ kubectl directpv discover
   
    Discovered node 'master' ✔
    Discovered node 'node1' ✔
   
   ┌─────────────────────┬────────┬───────┬─────────┬────────────┬──────┬───────────┬─────────────┐
   │ ID                  │ NODE   │ DRIVE │ SIZE    │ FILESYSTEM │ MAKE │ AVAILABLE │ DESCRIPTION │
   ├─────────────────────┼────────┼───────┼─────────┼────────────┼──────┼───────────┼─────────────┤
   │ 252:16$ud8mwCjPT... │ master │ vdb   │ 512 MiB │ -          │ -    │ YES       │ -           │
   │ 252:16$gGz4UIuBj... │ node1  │ vdb   │ 512 MiB │ -          │ -    │ YES       │ -           │
   └─────────────────────┴────────┴───────┴─────────┴────────────┴──────┴───────────┴─────────────┘

   Generated 'drives.yaml' successfully.

   # Show generated drives.yaml file.
   $ cat drives.yaml
   version: v1
   nodes:
       - name: master
         drives:
           - id: 252:16$ud8mwCjPTH8147TysmiQ2GGLpffqUht6bz7NtHqReJo=
             name: vdb
             size: 536870912
             make: ""
             select: "yes"
       - name: node1
         drives:
           - id: 252:16$gGz4UIuBjQlO1KibOv7bZ+kEDk3UCeBneN/UJdqdQl4=
             name: vdb
             size: 536870912
             make: ""
             select: "yes"
   
   ```

3. Run the [`init`]({{< relref "command-line/init.md" >}}) command.

   The `init` command creates a request to add the selected drives in the YAML file generated using the `discover` command in the previous step. 
   
   {{< admonition type="warning" >}}
   This process wipes out all data on the selected drives. 
   Wrong drive selection will lead to permanent data loss. 

   Before running this command, modify the yaml file to mark any undesired drives as `no` for the `select` field.
   {{< /admonition >}}
   
   Below is an example of `init` command:

   ```sh
   $ kubectl directpv init drives.yaml
   
   
    ███████████████████████████████████████████████████████████████████████████ 100%
   
    Processed initialization request 'c24e22f5-d582-49ba-a883-2ce56909904e' for node 'master' ✔
    Processed initialization request '7e38a453-88ed-412c-b146-03eef37b23bf' for node 'node1' ✔
   
   ┌──────────────────────────────────────┬────────┬───────┬─────────┐
   │ REQUEST_ID                           │ NODE   │ DRIVE │ MESSAGE │
   ├──────────────────────────────────────┼────────┼───────┼─────────┤
   │ c24e22f5-d582-49ba-a883-2ce56909904e │ master │ vdb   │ Success │
   │ 7e38a453-88ed-412c-b146-03eef37b23bf │ node1  │ vdb   │ Success │
   └──────────────────────────────────────┴────────┴───────┴─────────┘
   ```

Refer to the [discover command]({{< relref "command-line/discover.md" >}}) and the [init command]({{< relref "command-line/init.md" >}}) for more details and optional parameters.

### List drives

To get information of drives from DirectPV, run the `list drives` command. 

```sh
$ kubectl directpv list drives
┌────────┬──────┬──────┬─────────┬─────────┬─────────┬────────┐
│ NODE   │ NAME │ MAKE │ SIZE    │ FREE    │ VOLUMES │ STATUS │
├────────┼──────┼──────┼─────────┼─────────┼─────────┼────────┤
│ master │ vdb  │ -    │ 512 MiB │ 506 MiB │ -       │ Ready  │
│ node1  │ vdb  │ -    │ 512 MiB │ 506 MiB │ -       │ Ready  │
└────────┴──────┴──────┴─────────┴─────────┴─────────┴────────┘
```

Refer to the [list drives command]({{< relref "command-line/list-drives.md" >}}) for more information.

### Label drives

Drives are labeled to set custom tagging which can be used in volume provisioning. 

```sh
# Set label 'tier' key to 'hot' value.
$ kubectl directpv label drives tier=hot

# Remove label 'tier'.
$ kubectl directpv label drives tier-
```

Once set, use labels to [schedule drives]({{< relref "resource-management/scheduling.md" >}}).

Refer to the [label drives command]({{< relref "command-line/label-drives.md" >}}) for more information.

### Replace drive

Replace a faulty drive with a new drive on a same node. 
In this process, all volumes in the faulty drive are moved to the new drive then faulty drive is removed from DirectPV. 
Currently, DirectPV does not support moving data on the volume to the new drive. 
Use the [replace.sh]({{< relref "/resource-management/scripts.md#replace.sh" >}}) script to perform drive replacement. 

Below is an example:

```sh
# Replace 'sdd' drive by 'sdf' drive on 'node1' node
$ replace.sh sdd sdf node1
```

### Remove drives
Drives that do not contain any volumes can be removed. 

```sh
# Remove drive 'vdb' from 'node1' node
$ kubectl directpv remove --drives=vdb --nodes=node1
```

Refer to the [remove command]({{< relref "command-line/remove.md" >}}) for more information.
