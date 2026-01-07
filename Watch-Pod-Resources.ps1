param (
    [Parameter( Mandatory = $true )]
    [string] $n
)

Clear-Host

Write-Host ""
Write-Host "::: Watch-Pod-Resources.ps1 :::" -ForegroundColor Cyan
Write-Host ""

# Ensure ANSI escape sequences render correctly in modern terminals
if ( $PSStyle ) {
    $PSStyle.OutputRendering = 'Ansi'
} # END if ( $PSStyle )

while ( $true ) {

    [Console]::SetCursorPosition( 0, 0 )

    Write-Host ""
    Write-Host "::: Watch-Pod-Resources.ps1 :::" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Namespace: $n   (refreshed every 5 seconds)   $(Get-Date -Format HH:mm:ss)" -ForegroundColor Yellow
    Write-Host ""

    $pods = kubectl get pods -n $n -o json | ConvertFrom-Json
    $now  = Get-Date

    $output = foreach ( $pod in $pods.items ) {

        $created = [DateTime]::Parse( $pod.metadata.creationTimestamp )
        $age     = $now - $created

        $ageFormatted = if ( $age.Days -gt 0 ) {
            "{0}d {1:hh\:mm\:ss}" -f $age.Days, $age
        } else {
            "{0:hh\:mm\:ss}" -f $age
        }

        foreach ( $container in $pod.spec.containers ) {

            $status = $pod.status.containerStatuses |
                Where-Object { $_.name -eq $container.name }

            [PSCustomObject] @{
                Pod         = $pod.metadata.name
                Pod_Age     = $ageFormatted
                Container   = $container.name
                CPU_Request = $container.resources.requests.cpu
                CPU_Limit   = $container.resources.limits.cpu
                Mem_Request = $container.resources.requests.memory
                Mem_Limit   = $container.resources.limits.memory
                Restarts    = if ( $status ) { $status.restartCount } else { 0 }
            }

        } # END foreach ( $container )

    } # END foreach ( $pod )

    $tableText = $output |
        Sort-Object Pod, Container |
        Format-Table -AutoSize |
        Out-String

    Write-Host $tableText -NoNewline

    # IMPORTANT:
    # Clear ONLY the remainder of the screen AFTER printing.
    # This removes stale lines when pod count drops, without flashing.
    [Console]::Write( "`e[0J" )

    Start-Sleep -Seconds 5

} # END while ( $true )
