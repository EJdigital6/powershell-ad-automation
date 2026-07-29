[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$SamAccountName
)

$logFile = "C:\Lab\Offboarding_$($SamAccountName)_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"

function Write-Log {
    param([string]$Message)
    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$stamp  $Message" | Add-Content -Path $logFile -WhatIf:$false
    Write-Host $Message
}

try {
    $user = Get-ADUser -Identity $SamAccountName -Properties MemberOf, Description -ErrorAction Stop
}
catch {
    Write-Log "ABORT: User '$SamAccountName' not found. Nothing done."
    return
}

Write-Log "=== Offboarding started for $SamAccountName ==="

try {
    Disable-ADAccount -Identity $user -ErrorAction Stop
    Write-Log "SUCCESS: Account disabled"
}
catch {
    Write-Log "FAILED: Could not disable account — $_"
    Write-Log "ABORT: Stopping here — will not continue offboarding an enabled account."
    return
}

Write-Log "=== Offboarding finished for $SamAccountName ==="
