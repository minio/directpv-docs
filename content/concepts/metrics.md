---
title: Metrics and Monitoring
date: 2023-05-17
lastmod: :git
draft: false
tableOfContents: true
---

## Monitoring Guidelines

DirectPV nodes export Prometheus compatible metrics data via port `10443`. 

To scrape data in Prometheus, each node must be accessible by port `10443`. 

1. Make node server metrics port accessible by `localhost:8080`.
   
   ```sh {.copy}
   kubectl -n directpv port-forward node-server-4nd6q 8080:10443
   ```

2. Add the following to your Prometheus configuration:

   ```yaml {.copy}
   scrape_configs:
     - job_name: 'directpv-monitor'
       # Override the global default and scrape targets from this job every 5 seconds.
       scrape_interval: 5s
       static_configs:
         - targets: ['localhost:8080']
           labels:
             group: 'production'
   ```

3. Run a Prometheus query with PromQL in the Prometheus web interface to test the configuration.
  
   For example, the following query returns the total bytes metric for `node1`:

   ```promQL {.copy}
   directpv_stats_bytes_total{node="node1"}
   ```

## Supported Metrics

DirectPV node server exports the following metrics:

- directpv_stats_bytes_used
- directpv_stats_bytes_total

These metrics are categorized by labels ['tenant', 'volumeID', 'node'] and represent the volume stats of the published volumes.

## Configuration

Apply the following Prometheus config to scrape the metrics exposed:

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

For example, use the following PromQL to query the volume stats:

- To filter the volumes scheduled in `node-3`

  ```promql
  directpv_stats_bytes_total{node="node-3"}
  ```

- To filter the volumes of `tenant-1` scheduled in `node-5`

  ```promql
  directpv_stats_bytes_used{tenant="tenant-1", node="node-5"}
  ```
