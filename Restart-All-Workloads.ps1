param ( )

Write-Host ""
Write-Host "::: Restart-All-Workloads :::" -ForegroundColor Cyan
Write-Host ""

# Get all namespaces except kube-system
$namespaces = kubectl get namespaces `
    --no-headers `
    -o custom-columns=":metadata.name" |
    Where-Object { $_ -ne "kube-system" }

foreach ( $namespace in $namespaces ) {

    Write-Host ""
    Write-Host "Namespace: $namespace" -ForegroundColor Yellow

    #
    # Restart Deployments
    #
    $deployments = kubectl get deployments `
        -n $namespace `
        --no-headers `
        -o custom-columns=":metadata.name" `
        2>$null

    foreach ( $deployment in $deployments ) {
        Write-Host "  Restarting Deployment: $deployment"
        kubectl rollout restart deployment $deployment -n $namespace | Out-Null
    } # END foreach deployment

    #
    # Restart StatefulSets
    #
    $statefulsets = kubectl get statefulsets `
        -n $namespace `
        --no-headers `
        -o custom-columns=":metadata.name" `
        2>$null

    foreach ( $statefulset in $statefulsets ) {
        Write-Host "  Restarting StatefulSet: $statefulset"
        kubectl rollout restart statefulset $statefulset -n $namespace | Out-Null
    } # END foreach statefulset

    #
    # Restart DaemonSets
    #
    $daemonsets = kubectl get daemonsets `
        -n $namespace `
        --no-headers `
        -o custom-columns=":metadata.name" `
        2>$null

    foreach ( $daemonset in $daemonsets ) {
        Write-Host "  Restarting DaemonSet: $daemonset"
        kubectl rollout restart daemonset $daemonset -n $namespace | Out-Null
    } # END foreach daemonset

    #
    # Restart Argo Rollouts
    #
    $rollouts = kubectl get rollouts `
        -n $namespace `
        --no-headers `
        -o custom-columns=":metadata.name" `
        2>$null

    foreach ( $rollout in $rollouts ) {
        Write-Host "  Restarting Rollout: $rollout"
        kubectl argo rollouts restart rollout $rollout -n $namespace | Out-Null
    } # END foreach rollout

} # END foreach namespace

Write-Host ""
Write-Host "All eligible workloads restarted successfully." -ForegroundColor Green
Write-Host ""
