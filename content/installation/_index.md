---
title: Install DirectPV
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
heading: true
weight: 10
---

## Prerequisites

| Name                                                            | Version  |
| ----------------------------------------------------------------|----------|
| kubernetes                                                      | v1.19+   |
| [kubectl](https://kubernetes.io/docs/tasks/tools/)              | v1.19+   |
| [krew](https://krew.sigs.k8s.io/docs/user-guide/setup/install/) | v0.4.3+  |

## Production Readiness Checklist

Make sure the following check-boxes are ticked before production deployment

 - [ ] If using a private registry, make all the images listed in [air-gapped installation images](#air-gapped-installation-private-registry) available in the private registry.
 - [ ] If using seccomp on the system, load the DirectPV [seccomp policy](https://raw.githubusercontent.com/minio/directpv/master/seccomp.json) on all nodes. 
 
   For more detailed instructions on seccomp, refer to the [Kubernetes documentation](https://kubernetes.io/docs/tutorials/clusters/seccomp/)
 - [ ] If using AppArmor on the system, load the DirectPV [apparmor profile](https://raw.githubusercontent.com/minio/directpv/master/apparmor.profile) on all nodes. 
      
   For more detailed instructions on AppArmor in Kubernetes environment, refer to the [Kubernetes documentation](https://kubernetes.io/docs/tutorials/clusters/apparmor/).

## Plugin Installation

1. Install DirectPV to your krew installation directory (default: `$HOME/.krew`):

   ```sh {.copy}
   kubectl krew install directpv
   ```

2. Run `kubectl directpv --version` to verify DirectPV installed correctly
 
   If you receive the error  `Error: unknown command "directpv" for "kubectl"`, add `$HOME/.krew/bin` to your `$PATH`.

## Driver Installation

{{< admonition type="note" >}}
For installation in production grade environments, ensure you satisfy all criteria in the [Production Readiness Checklist](#production-readiness-checklist).
{{< /admonition >}}

The installation process creates a new storage class named `directpv-min-io`.
You can provision DirectPV volumes by using this storage class as the `storageClassName` in `PodSpec.VolumeClaimTemplates`.

For an example of using `directpv-min-io`, see the [MinIO example on GitHub](https://github.com/minio/directpv/blob/master/functests/minio.yaml#L62).

<!-- - view the [usage guide](./usage-guide.md) -->

Refer to the [CLI Guide]({{< relref "command-line/_index.md" >}}) for more helpers on the following commands.

### Install the driver

Install the `directpv-min-io` CSI driver in the kubernetes cluster.

```sh {.copy}
kubectl directpv install
```


- DirectPV components install in the namespace `directpv`.
- Specify an alternate kubeconfig with `kubectl directpv --kubeconfig /path/to/kubeconfig`.
- The DirectPV driver requires the Role Based Access Control (RBAC) listed in the [specification document]({{< relref "concepts/specification.md#driver-rbac" >}})
- The DirectPV driver runs in `privileged` mode, required to mount, unmount, and format drives.
- The deamonset used by DirectPV requires the following open ports:
  - `10443` for metrics 
  - Port `30443` for readiness handlers

### List discovered drives

List all available drives in the kubernetes cluster.
DirectPV generates an `init` config file (default: `drives.yaml`) you can use to initialize these drives.

```sh {.copy}
kubectl directpv discover
```

Check the contents of the file and modify the file as needed to remove any drives that DirectPV should not control.

### Initialize the drives

```sh {.copy}
kubectl directpv init drives.yaml
```

Initialize the drives selected in `drives.yaml`


{{< admonition title="Potential Data Loss" type="warning" >}}
Initialization erases all existing data on the drives. 
Verify that only intended drives are specified in the file passed to the init command.
{{< /admonition >}}

### Verify installation

After initializing the drives, show information about the drives formatted and added to DirectPV.

```sh {.copy}
kubectl directpv info
```


## Air-gapped Installation (Private Registry)

Push the following images to your private registry
 
 - quay.io/minio/csi-node-driver-registrar:v2.6.3
 - quay.io/minio/csi-provisioner:v3.4.0
 - quay.io/minio/livenessprobe:v2.9.0
 - quay.io/minio/csi-resizer:v1.7.0
 - quay.io/minio/directpv:latest
 
 **Notes:**

 - If you use a Kubernetes version earlier than v1.20, you need to push `quay.io/minio/csi-provisioner:v2.2.0-go1.18`

Use the following shell script to do the above steps:

```sh {.copy}
/bin/bash -e

# set this to private registry URL (the URL should NOT include http or https)
if [ -z $PRIVATE_REGISTRY_URL ]; then "PRIVATE_REGISTRY_URL env var should be set"; fi

images[0]=quay.io/minio/csi-node-driver-registrar:v2.6.3
images[1]=quay.io/minio/csi-provisioner:v3.4.0
images[2]=quay.io/minio/livenessprobe:v2.9.0
images[3]=quay.io/minio/csi-resizer:v1.7.0
images[4]=quay.io/minio/directpv:$(curl -s "https://api.github.com/repos/minio/directpv/releases/latest" | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/')

function privatize(){ echo $1 | sed "s#quay.io#${PRIVATE_REGISTRY_URL}#g"; }
function pull_tag_push(){ docker pull $1 &&  docker tag $1 $2 && docker push $2; }
for image in ${images[*]}; do pull_tag_push $image $(privatize $image); done
```

## Custom Installation

To perform additional customizations, generate an install yaml file, customize it, then use the file to install DirectPV.

1. Generate the specification for installing DirectPV.

   ```sh {.copy}
   kubectl directpv install -o yaml > directpv-install.yaml
   ```

2. Open the generated file in a text editor and make changes.
   This command uses the CLI editor `nano`.
  
   ```sh {.copy}
   nano directpv-install.yaml
   ```

   Replace `nano` with your preferred text editor.

3. Install a customized DirectPV

   ```sh {.copy}
   kubectl create -f directpv-install.yaml
   ```

{{< admonition title="Updating Custom Installations" type="important" >}}
Custom installations do not support client-side upgrade functionality. 
Use `kubectl directpv migrate` to migrate the old resources to a new installation.
{{< /admonition >}}


