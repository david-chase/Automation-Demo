param ()

Write-Host ""
Write-Host "::: Restart-RetailStore-Workloads.ps1 :::" -ForegroundColor Cyan
Write-Host ""

# =====================================================================
# Script: Restart-RetailStore-Workloads.ps1
#
# Description:
#   Restarts all Deployments and StatefulSets in every namespace
#   whose name starts with "retailstore-".
#
#   Uses kubectl rollout restart (safe, non-destructive).
# =====================================================================

# Get all retailstore namespaces (robust for Windows PowerShell)
$Namespaces = kubectl get ns -o name |
  ForEach-Object { $_ -replace '^namespace/', '' } |
  Where-Object { $_ -like 'retailstore-*' }

if ( -not $Namespaces ) {
    Write-Host "No retailstore namespaces found." -ForegroundColor Yellow
    return
} # END if ( -not $Namespaces )

foreach ( $Namespace in $Namespaces ) {

    Write-Host ""
    Write-Host "Processing namespace: $Namespace" -ForegroundColor Green

    # Restart Deployments
    $Deployments = kubectl get deployments -n $Namespace -o name |
      ForEach-Object { $_ -replace '^deployment.apps/', '' }

    foreach ( $Deployment in $Deployments ) {
        Write-Host "Restarting Deployment: $Deployment"
        kubectl rollout restart deployment $Deployment -n $Namespace
    } # END foreach ( $Deployment in $Deployments )

    # Restart StatefulSets
    $StatefulSets = kubectl get statefulsets -n $Namespace -o name |
      ForEach-Object { $_ -replace '^statefulset.apps/', '' }

    foreach ( $StatefulSet in $StatefulSets ) {
        Write-Host "Restarting StatefulSet: $StatefulSet"
        kubectl rollout restart statefulset $StatefulSet -n $Namespace
    } # END foreach ( $StatefulSet in $StatefulSets )

} # END foreach ( $Namespace in $Namespaces )

Write-Host ""
Write-Host "Restart operation completed for all retailstore namespaces." -ForegroundColor Cyan
Write-Host ""
