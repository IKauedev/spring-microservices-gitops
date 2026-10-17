<#
  Instala o Chaos Mesh no cluster atual do minikube (opcional, sob demanda).
  Uso:  .\chaos\chaos-on.ps1 [-Runtime docker|containerd] [-Dashboard]
#>
param(
    [ValidateSet('docker', 'containerd')]
    [string]$Runtime = 'docker',
    [switch]$Dashboard
)

$ErrorActionPreference = 'Stop'

$socket = if ($Runtime -eq 'docker') { '/var/run/docker.sock' } else { '/run/containerd/containerd.sock' }

helm repo add chaos-mesh https://charts.chaos-mesh.org 2>$null | Out-Null
helm repo update chaos-mesh

helm upgrade --install chaos-mesh chaos-mesh/chaos-mesh `
    --namespace chaos-mesh --create-namespace `
    --set chaosDaemon.runtime=$Runtime `
    --set chaosDaemon.socketPath=$socket `
    --set dashboard.securityMode=false `
    --wait --timeout 5m

Write-Host "`nChaos Mesh instalado. Experimentos em .\chaos\experiments (kubectl apply -f <arquivo>)." -ForegroundColor Green

if ($Dashboard) {
    Write-Host "Dashboard em http://localhost:2333 (Ctrl+C para fechar o port-forward)" -ForegroundColor Cyan
    kubectl port-forward -n chaos-mesh svc/chaos-dashboard 2333:2333
}
