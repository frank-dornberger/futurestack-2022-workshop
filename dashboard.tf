resource "newrelic_one_dashboard" "k8s-optimizer" {
  name = "k8s Optimizer"

  page {
    name = "k8s Optimizer"

    widget_pie {
      title = "Nodes per Cluster -> SELECT A CLUSTER"
      row = 1
      height = 3
      column = 1
      width = 4
      filter_current_dashboard = true

      nrql_query {
          query = "SELECT uniqueCount(nodeName) FROM K8sContainerSample FACET clusterName LIMIT MAX"
      }
    }

    widget_pie {
      title = "Deployments per Namespace -> SELECT A NAMESPACE"
      row = 1
      height = 3
      column = 5
      width = 4
      filter_current_dashboard = true

      nrql_query {
          query = "SELECT uniqueCount(deploymentName) FROM K8sContainerSample FACET namespaceName LIMIT MAX"
      }
    }

    widget_bar {
      title = "Current Replications per Container -> SELECT A CONTAINER"
      row = 1
      height = 3
      column = 9
      width = 4
      filter_current_dashboard = true

      nrql_query {
          query = "SELECT uniqueCount(containerID) FROM K8sContainerSample SINCE 5 minutes ago FACET containerName LIMIT MAX"
      }
    }

    widget_billboard {
      title = "CURRENT Resource Configuration"
      row = 4
      height = 3
      column = 1
      width = 2

      nrql_query {
        query = <<-EOT
        SELECT latest(cpuRequestedCores) AS 'CPU request', 
        latest(cpuLimitCores) AS 'CPU limit', 
        latest(memoryRequestedBytes/1024/1024) AS 'Memory request (MB)', 
        latest(memoryLimitBytes/1024/1024) AS 'Memory limit (MB)' 
        FROM K8sContainerSample SINCE 1 week ago
        EOT
      }
    }

    widget_billboard {
      title = "SUGGESTED Resource Configuration"
      row = 4
      height = 3
      column = 3
      width = 2

      nrql_query {
        query = <<-EOT
        SELECT percentile(cpuUsedCores, 95) * (1 + (var.cpu_request_margin)/100) AS 'CPU request', 
        percentile(cpuUsedCores, 95) * (1 + (var.cpu_limit_margin)/100) AS 'CPU limit', 
        percentile(memoryUsedBytes/1024/1024, 95) * (1 + (var.memory_request_margin)/100) AS 'Memory request (MB)', 
        percentile(memoryUsedBytes/1024/1024, 95) * (1 + (var.memory_limit_margin)/100) AS 'Memory limit (MB)' 
        FROM K8sContainerSample SINCE 1 week ago
        EOT
      }
    }

    widget_line {
      title = "Contra Indication to reduce CPU limit: High number of Throttles"
      row = 4
      height = 3
      column = 5
      width = 8

      nrql_query {
        query = "SELECT sum(containerCpuCfsThrottledPeriodsDelta) FROM K8sContainerSample SINCE 1 week ago FACET containerName TIMESERIES MAX"
      }
    }

    widget_markdown {
      title = "Dashboard Note"
      row    = 7
      height = 3
      column = 1
      width = 2

      text = <<-EOT
      # Caveat

      **Use the suggestions as a recommendation for review, and test well before shipping to Production.**

      # Explanation

      **The mechanics behind k8s resources are explained here:** https://blog.kubecost.com/blog/requests-and-limits/
      EOT
    }

    widget_billboard {
      title = "Resource Savings per Replica"
      row = 7
      height = 3
      column = 3
      width = 2

      nrql_query {
        query = <<-EOT
        SELECT latest(cpuRequestedCores) - (percentile(cpuUsedCores, 95) * (1 + (var.cpu_request_margin)/100)) AS 'CPU request', 
        latest(cpuLimitCores) - (percentile(cpuUsedCores, 95) * (1 + (var.cpu_limit_margin)/100)) AS 'CPU limit', 
        latest(memoryRequestedBytes/1024/1024) - (percentile(memoryUsedBytes/1024/1024, 95) * (1 + (var.memory_request_margin)/100)) AS 'Memory request (MB)', 
        latest(memoryLimitBytes/1024/1024) - (percentile(memoryUsedBytes/1024/1024, 95) * (1 + (var.memory_limit_margin)/100)) AS 'Memory limit (MB)' 
        FROM K8sContainerSample SINCE 1 week ago
        EOT
      }
      
      # colors any resource savings in green, and any increase in orange
      critical = -50000
      warning = -0.01     
    }

    widget_line {
      title = "Contra Indication to reduce Memory limit: High number of Restarts"
      row = 7
      height = 3
      column = 5
      width = 8

      nrql_query {
        query = "SELECT sum(restartCount) FROM K8sContainerSample SINCE 1 week ago FACET containerName TIMESERIES MAX"
      }
    }

    widget_line {
      title = "CPU Utilization per Container (TP95)"
      row    = 10
      height = 3
      column = 1
      width = 6

      nrql_query {
        query = "SELECT percentile(cpuUsedCores, 95) FROM K8sContainerSample SINCE 1 week ago FACET containerID TIMESERIES MAX LIMIT MAX"
      }
    }

    widget_line {
      title = "Memory Utilization per Container (TP95)"
      row    = 10
      height = 3
      column = 7
      width = 6

      nrql_query {
        query = "SELECT percentile(memoryUsedBytes/1024/1024, 95) FROM K8sContainerSample SINCE 1 week ago FACET containerID TIMESERIES MAX LIMIT MAX"
      }
    }

    widget_table {
      title = "Table with all values for export (Export as CSV) ----->"
      row    = 13
      height = 3
      column = 1
      width = 12

      nrql_query {
        query = <<-EOT
        SELECT latest(cpuRequestedCores) AS 'current CPU request', 
        percentile(cpuUsedCores, 95) * (1 + (var.cpu_request_margin)/100) AS 'suggested CPU request', 
        latest(cpuLimitCores) AS 'current CPU limit', 
        percentile(cpuUsedCores, 95) * (1 + (var.cpu_limit_margin)/100) AS 'suggested CPU limit', 
        average(containerCpuCfsThrottledPeriodsDelta) AS 'Avg. Throttles', 
        latest(memoryRequestedBytes/1024/1024) AS 'current Memory request (MB)', 
        percentile(memoryUsedBytes/1024/1024, 95) * (1 + (var.memory_request_margin)/100) AS 'suggested Memory request (MB)', 
        latest(memoryLimitBytes/1024/1024) AS 'current Memory limit (MB)', 
        percentile(memoryUsedBytes/1024/1024, 95) * (1 + (var.memory_limit_margin)/100) AS 'suggested Memory limit (MB)', 
        average(restartCount) AS 'Avg. Restarts'
        FROM K8sContainerSample SINCE 1 month ago 
        FACET namespace, containerName AS 'Container', clusterName AS 'Cluster' 
        LIMIT MAX
        EOT
      }
    }
  }
}