param (
    [Parameter( Mandatory = $true )]
    [string] $n,
    
    [Parameter( Mandatory = $false )]
    [Alias("s")]
    [switch] $silent
)

if (-not $silent) {
    Clear-Host

    Write-Host ""
    Write-Host "::: Drain-Node.ps1 :::" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Draining node: $n" -ForegroundColor Yellow
    Write-Host ""
}

if ($silent) {
    kubectl drain $n `
        --ignore-daemonsets `
        --delete-emptydir-data `
        --force `
        2>&1 | Out-Null
} else {
    kubectl drain $n `
        --ignore-daemonsets `
        --delete-emptydir-data `
        --force
}

if (-not $silent) {
    Write-Host ""
    Write-Host "Drain operation completed for node: $n" -ForegroundColor Green
    Write-Host ""
}
