# AKS setup using Terraform and Helm
[![License](https://img.shields.io/:license-MIT-green.svg)](https://github.com/Misha999777/aks-terraform/blob/main/LICENSE)

This repository contains Terraform code and related configurations to
create and manage an **Azure Kubernetes Service (AKS)**, set up key integrations,
and deploy a demo app demonstrating functionality.

## Features

- **AKS Cluster** with auto-scalable node pool
- **Storage Account** for the application to store blobs
- **Workload Identity** to access Azure services
- Creation of a **DNS zone** and registering its NS Records in Cloudflare
- External DNS using **Azure Web Apps**
- ACME certificate management for secure HTTPS setup using **cert-manager**
- **Helm-based deployment** of the demo app with an ingress
- **GitHub Actions** for CI/CD and **Terraform Cloud (TFC)** for infrastructure deployment
