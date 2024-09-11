import os

from http.server import BaseHTTPRequestHandler, HTTPServer

from kubernetes import client, config

from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential

NAMESPACE = 'cgm'

def connect_to_storage_with_identity():
    try:
        client_identity = BlobServiceClient(
            account_url="https://cgmt.blob.core.windows.net",
            credential=DefaultAzureCredential()
        )
        containers = client_identity.list_containers()
        container_names = [container.name for container in containers]
        return container_names
    except Exception as e:
        return []

def list_kubernetes_pods(namespace):
    try:
        config.load_incluster_config()
        
        v1 = client.CoreV1Api()
        pods = v1.list_namespaced_pod(namespace)
        
        pod_names = [pod.metadata.name for pod in pods.items]
        return pod_names
    except Exception as e:
        return []

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        pod_names = list_kubernetes_pods(NAMESPACE)

        container_names = connect_to_storage_with_identity()

        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()

        response_message = (
            f"Hello, this is a simple HTTP server!\n"
            f"Kubernetes Pods in '{NAMESPACE}': {', '.join(pod_names)}\n"
            f"Azure Storage Containers: {', '.join(container_names)}"
        )
        self.wfile.write(response_message.encode('utf-8'))

if __name__ == "__main__":
    server_address = ('', 80)
    httpd = HTTPServer(server_address, SimpleHTTPRequestHandler)

    httpd.serve_forever()
