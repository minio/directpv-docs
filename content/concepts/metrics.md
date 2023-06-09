---
title: Metrics and Monitoring
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Monitoring Guidelines

DirectPV nodes export Prometheus compatible metrics data by exposing a metrics endpoint at `/directpv/metrics`. 
Users looking to monitor their tenants can point their Prometheus configuration to scrape data from this endpoint.

## Supported Metrics

DirectPV node server exports the following metrics:

- directpv_stats_bytes_used
- directpv_stats_bytes_total

These metrics are categorized by labels ['tenant', 'volumeID', 'node'] and represent the volume stats of the published volumes.

## Configuration

Apply the following Prometheus config to scrape the metrics exposed. 

```yaml {.copy}
global:
  scrape_interval: 15s
  external_labels:
    monitor: 'directpv-monitor'

scrape_configs:

- job_name: 'directpv-metrics'
  scheme: http
  metrics_path: /directpv/metrics
  authorization:
    credentials_file: /var/run/secrets/kubernetes.io/serviceaccount/token

  kubernetes_sd_configs:
  - role: pod

  relabel_configs:
  - source_labels: [__meta_kubernetes_namespace]
    regex: "directpv-(.+)"
    action: keep
  - source_labels: [__meta_kubernetes_pod_controller_kind]
    regex: "DaemonSet"
    action: keep
  - source_labels: [__meta_kubernetes_pod_container_port_name]
    regex: "healthz"
    action: drop
    target_label: kubernetes_port_name

- job_name: 'kubernetes-cadvisor'
  scheme: https
  metrics_path: /metrics/cadvisor
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    insecure_skip_verify: true
  authorization:
    credentials_file: /var/run/secrets/kubernetes.io/serviceaccount/token

  kubernetes_sd_configs:
  - role: node

  relabel_configs:
  - action: labelmap
    regex: __meta_kubernetes_node_label_(.+)
  - source_labels: [__meta_kubernetes_namespace]
    action: replace
    target_label: kubernetes_namespace
  - source_labels: [__meta_kubernetes_service_name]
    action: replace
    target_label: kubernetes_name
```

## Filtering

Prometheus supports filtering results with the [PromQL language](https://prometheus.io/docs/prometheus/latest/querying/basics/).

For example, use the following promQL to query the volume stats.

- To filter the volumes scheduled in `node-3`

  ```promql
  directpv_stats_bytes_total{node="node-3"}
  ```

- To filter the volumes of `tenant-1` scheduled in `node-5`

  ```promql
  directpv_stats_bytes_used{tenant="tenant-1", node="node-5"}
  ```
