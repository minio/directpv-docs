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
| Kubernetes                                                      | v1.19+   |
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

Install the DirectPV plugin in your local environment to manage the DirectPV CSI Driver in your Kubernetes cluster.
You can install using `krew` or as a binary.


### Install DirectPV Plugin with `krew`

The latest DirectPV plugin is available in the `Krew` repository.

1. Update `Krew` to download the latest version of the plugin

   ```sh {.copy}
   kubectl krew update
   ```

2. Install DirectPV to your krew installation directory (default: `$HOME/.krew`):

   ```sh {.copy}
   kubectl krew install directpv
   ```

3. Run `kubectl directpv --version` to verify DirectPV installed correctly
 
   If you receive the error  `Error: unknown command "directpv" for "kubectl"`, add `$HOME/.krew/bin` to your `$PATH`.

### Install DirectPV Plugin as a binary

The plugin binary name starts with `kubectl-directpv` and is available at https://github.com/minio/directpv/releases/latest. 
Download the binary for your operating system and architecture.
You may need to move the file to a location available to your system path.

Refer to the documentation for your operating system for instructions on how to make a binary file executable and how to run the file.
Detailed instructions for every available operating system are out of scope for this documentation.

Below is an example for `GNU/Linux` on `amd64` architecture:

```sh {.copy}
# Download DirectPV plugin.
$ release=$(curl -sfL "https://api.github.com/repos/minio/directpv/releases/latest" | awk '/tag_name/ { print substr($2, 3, length($2)-4) }')
$ curl -fLo kubectl-directpv https://github.com/minio/directpv/releases/download/v${release}/kubectl-directpv_${release}_linux_amd64
# Make the binary executable.
$ chmod a+x kubectl-directpv
$ mv kubectl-directpv /usr/local/bin/kubectl-directpv
```

## Driver Installation

Install the DirectPV Driver to your Kubernetes deployment.

{{< admonition type="note" >}}
For installation in production grade environments, ensure you satisfy all criteria in the [Production Readiness Checklist](#production-readiness-checklist).
{{< /admonition >}}

### Prerequisites

* Kubernetes >= v1.18 on GNU/Linux on amd64.
 
* If you use private registry, below images must be pushed into your registry. You could use [this helper script]({{< relref "drives/scripts.md#push-images.sh" >}}) to do that.
  - quay.io/minio/csi-node-driver-registrar:v2.8.0
  - quay.io/minio/csi-provisioner:v3.5.0 _(for Kubernetes >= v1.20)_
  - quay.io/minio/csi-provisioner:v2.2.0-go1.18 _(for kubernetes < v1.20)_
  - quay.io/minio/livenessprobe:v2.10.0
  - quay.io/minio/csi-resizer:v1.8.0
  - quay.io/minio/directpv:latest

* If `seccomp` is enabled, load [DirectPV seccomp profile](../seccomp.json) on nodes where you want to install DirectPV and use `--seccomp-profile` flag to [`kubectl directpv install`]({{< relref "command-line/install.md" >}}) command. 
 
  For more information, refer to the Kubernetes documentation on [seccomp](https://kubernetes.io/docs/tutorials/clusters/seccomp/)

* If `apparmor` is enabled, load [DirectPV apparmor profile]([../apparmor.profile](https://raw.githubusercontent.com/minio/directpv/master/apparmor.profile)) on nodes where you want to install DirectPV and use `--apparmor-profile` flag to `kubectl directpv install` command. 
  
  For more information, refer to the [Kubernetes documentation on apparmor](https://kubernetes.io/docs/tutorials/clusters/apparmor/).

* Enabled `ExpandCSIVolumes` [feature gate](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/) for [volume expansion](https://kubernetes-csi.github.io/docs/volume-expansion.html) feature.

* Review the [driver specification documentation]({{< relref "concepts/specification.md" >}})

* For Red Hat Openshift users, refer to the [Openshift specific documentation]({{< relref "installation/openshift.md" >}}) for configuration prior to installing DirectPV.

### Procedure
The installation process creates a new storage class named `directpv-min-io`.
You can provision DirectPV volumes by using this storage class as the `storageClassName` in `PodSpec.VolumeClaimTemplates`.

For an example of using `directpv-min-io`, see the [MinIO example on GitHub](https://github.com/minio/directpv/blob/master/functests/minio.yaml#L62).

<!-- - view the [usage guide](./usage-guide.md) -->

Refer to the [CLI Guide]({{< relref "command-line/_index.md" >}}) for more helpers on the following commands.

### Install the driver

Install the `directpv-min-io` CSI driver on all nodes in the kubernetes cluster.

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

{{< admonition type="note" >}}
To install DirectPV on selected nodes, using tolerations, or with a non-standard `kubelet` directory, see the [custom installation](#custom-installation) section below.
{{< /admonition >}}

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

### Install on Selected Nodes

To install DirectPV on selected nodes, use `--node-selector` flag to `install` command. 

```sh
kubectl directpv info
# Install DirectPV on nodes having label 'group-name' key and 'bigdata' value
$ kubectl directpv install --node-selector group-name=bigdata
```

### Installing on tainted nodes
To install DirectPV on tainted nodes, use `--toleration` flag to `install` command.

The following example installs DirectPV on tainted nodes by tolerating 'key1' key where the value of the key is 'PVs' value with 'NoSchedule' effect

```sh {.copy}
kubectl directpv install --tolerations key1=PVs:NoSchedule
```

The following example installs DirectPV on tainted nodes by tolerating the existence of the 'key2' key (regardless of any value assigned to the key), with the 'NoExecute' effect.

```sh {.copy}
$ kubectl directpv install --tolerations key2:NoExecute
```

### Installing on non-standard `kubelet` directory

To install on non-standard `kubelet` directory, set the `KUBELET_DIR_PATH` environment variable before starting the installation.

```sh {.copy}
export KUBELET_DIR_PATH=/path/to/my/kubelet/dir
kubectl directpv install
```

### Installing on Openshift

To install DirectPV on Openshift with specific configuration, use the `--openshift` flag.

```sh {.copy}
$ kubectl directpv install --openshift
```

### Install with a Script


The following command downloads and runs an install.sh script file to perform a standard installation of DirectPV on all nodes.

```sh {.copy}
curl -sfL https://github.com/minio/directpv/raw/master/docs/tools/install.sh | sh - apply
```
