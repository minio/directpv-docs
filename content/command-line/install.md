---
title: install
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Description

Installs DirectPV in your kubernetes cluster.

## Syntax

```sh
kubectl directpv install [flags]
```

## Parameters

### Flags

| **Flag**                          | **Description**                                                        |
|-----------------------------------|------------------------------------------------------------------------|
| `--apparmor-profile` \<string\>   | Path to Apparmor profile                                               |
| `--image` \<string\>              | Name of the DirectPV image (default `directpv:4.0.6`)                  |
| `--image-pull-secrets` \<string\> | Image pull secrets for DirectPV images (`SECRET1,`..)                  |
| `--kube-version` \<string\>       | Kubernetes version to use for manifest generation (default "1.27.0")   |
| `--legacy`                        | Enable legacy mode (Used with '-o')                                    |
| `--node-selector` \<string\>      | Select the storage nodes using labels (`KEY=VALUE,`..)                 |
| `-o`, `--output` \<string\>       | Generate installation manifest. Specify the format as `yaml` or `json` |
| `--openshift`                     | Use an OpenShift specific installation                                 |
| `--org` \<string\>                | Organization name in the registry (default `minio`)                    |
| `--registry` \<string\>           | Name of container registry (default "quay.io")                         |
| `--seccomp-profile` \<string\>    | Path to Seccomp profile                                                |
| `--tolerations` \<string\>        | Set toleration labels on the storage nodes (`KEY[=VALUE]:EFFECT,`..)   |

### Global Flags

You can use the following global DirectPV flags with `kubectl directpv install`:

| **Flag**                  | **Description**                                        |
|---------------------------|--------------------------------------------------------|
| `--kubeconfig` \<string\> | Path to the `kube.config` file to use for CLI requests |
| `--quiet`                 | Suppress printing error messages                       |

## Examples

### Install DirectPV

The following command installs DirectPV with all default options.

```sh {.copy}
kubectl directpv install
```

### Install DirectPV from private registry 

The following command installs DirectPV using images from a private registry at `private-registry.io` for the org `my-org-name`.

```sh {.copy}
kubectl directpv install --registry private-registry.io --org my-org-name
```

### Deploy DirectPV pods on select nodes

The following command deploys the DirectPV daemonset only on pods on the specified node.

```sh {.copy}
kubectl directpv install --node-selector node-label-key=node-label-value
```

Replace `node-label-key` with the label key used as the selector.
Replace `node-label-value` with the value for the key on the nodes you want to install DirectPV on.

### Use tolerations to control placement of DirectPV pods

The following command uses tolerations to limit where DirectPV installs.
The tolerations take the form of `key=value:effect`.

```sh {.copy}
kubectl directpv install --tolerations key=value:NoSchedule
```

### Generate a DirectPV installation manifest file

The following command generates a YAML manifest file that can be used to install DirectPV.

```sh {.copy}
kubectl directpv install -o yaml > directpv-install.yaml
```

### Install DirectPV with an AppArmor profile

The following command installs DirectPV using an [AppArmor profile](https://en.wikipedia.org/wiki/AppArmor).

```sh {.copy}
kubectl directpv install --apparmor-profile directpv
```

### Install DirectPV with a seccomp profile

The following command installs DirectPV using a [seccomp profile](https://en.wikipedia.org/wiki/Seccomp).

```sh {.copy}
kubectl directpv install --seccomp-profile profiles/seccomp.json
```