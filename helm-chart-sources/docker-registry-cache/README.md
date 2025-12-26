# Docker Distribution Proxy Helm Chart

This repository contains a Helm chart designed to deploy a fully functional caching proxy for any container registry repositories. Based on the official Docker Distribution project (https://github.com/distribution/distribution), this chart facilitates launching multiple Distribution instances configured as caching proxies.

## Overview

The chart allows you to deploy one or more Docker Distribution instances that serve as caching proxies for upstream container registries. This enables faster and more reliable access to container images by storing requested content locally, reducing repeated downloads from remote registries.

Each Distribution instance is configured according to the official Docker Distribution configuration reference available at:

- [Docker Distribution Configuration](https://distribution.github.io/distribution/about/configuration/#storage)

This standard compliance ensures flexibility in defining storage backends, authentication, middleware, and other advanced options.

## Key Features

- **Multi-instance deployment:** Easily scale the number of proxy instances using Helm's replica management.
- **Flexible storage backends:** Support for various storage drivers such as filesystem, AWS S3, Google Cloud Storage, Azure Blob Storage, and in-memory modes.
- **Configurable caching and garbage collection:** Manage local cache lifecycle with scheduled garbage collection of untagged content.
- **Support for TLS termination:** Integrates with CertManager or Kubernetes secrets for TLS, or allows secure ingress configuration.
- **Integration with Kubernetes Ingress and Istio:** Options to expose services via standard Ingress or Istio virtual services and gateways.
- **Security best practices:** Default container and pod security contexts aligned with Kubernetes recommendations.
- **Extensible via extra environment variables, volumes, and middleware:** Customize deployments as required.

## Configuration

All core configuration options for the Distribution instances are passed via `values.yaml`, including:

- Image repository and tag
- Exposure type (`ingress` or `istio`)
- Storage backend and parameters in line with the official config syntax
- Replica count and update strategy
- Security contexts and resource requests
- Persistence volume claims and access modes
- Garbage collection scheduling and behavior
- Logging and metrics settings
- Proxying upstream registry URLs and credentials

For detailed configuration reference, please consult the [values.yaml](./values.yaml) file included in this chart.

## Usage

1. Customize `values.yaml` to specify desired proxy repositories, storage backends, and exposure methods.

2. Install the Helm chart with:

    ```bash
    helm install my-docker-proxy ./docker-registry -f values.yaml
    ```

3. Upgrade or manage the deployment using standard Helm commands.

## References

- [Docker Distribution Configuration Documentation](https://distribution.github.io/distribution/about/configuration/#storage)
- [Helm Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Kubernetes Official Documentation](https://kubernetes.io/docs/home/)
- [Istio Documentation (if using Istio exposure)](https://istio.io/latest/docs/)
