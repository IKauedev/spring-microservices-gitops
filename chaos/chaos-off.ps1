<#
  Remove todos os experimentos e desinstala o Chaos Mesh do cluster.
  Uso:  .\chaos\chaos-off.ps1
#>
$ErrorActionPreference = 'Continue'

# remove experimentos ativos antes de desinstalar, para nao deixar finalizers pendurados
$kinds = 'podchaos,networkchaos,stresschaos,schedule,workflow'
kubectl delete $kinds --all -A --ignore-not-found 2>$null

helm uninstall chaos-mesh -n chaos-mesh 2>$null
kubectl delete namespace chaos-mesh --ignore-not-found

# CRDs ficam para tras no helm uninstall
kubectl get crd -o name | Select-String 'chaos-mesh.org' | ForEach-Object {
    kubectl delete $_.ToString().Trim() --ignore-not-found
}

Write-Host "Chaos Mesh removido." -ForegroundColor Green
