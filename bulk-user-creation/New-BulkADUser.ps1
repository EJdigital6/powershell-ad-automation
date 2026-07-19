[CmdletBinding(SupportsShouldProcess = $true)]
param()

$logFile = "C:\Lab\BulkADUser_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"

function Write-Log {
    param([string]$Message)
    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$stamp  $Message" | Add-Content -Path $logFile -WhatIf:$false
    Write-Host $Message
}

if ($WhatIfPreference) {
    Write-Log "=== DRY RUN started (no changes will be made). CSV: C:\Lab\NewUsers.csv ==="
}
else {
    Write-Log "=== Run started. CSV: C:\Lab\NewUsers.csv ==="
}

$users = Import-Csv -Path "C:\Lab\NewUsers.csv"
$password = ConvertTo-SecureString "TempPass123!" -AsPlainText -Force

foreach ($user in $users) {
    $baseSam = "$($user.FirstName.ToLower()).$($user.LastName.ToLower())"
    $sam = $baseSam
    $counter = 2

    while (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
        $sam = "$baseSam$counter"
        $counter++
    }

    try {
        New-ADUser -Name $sam `
            -DisplayName "$($user.FirstName) $($user.LastName)" `
            -GivenName $user.FirstName `
            -Surname $user.LastName `
            -SamAccountName $sam `
            -UserPrincipalName "$sam@lab.local" `
            -Department $user.Department `
            -Title $user.JobTitle `
            -Path "OU=TestUsers,DC=lab,DC=local" `
            -AccountPassword $password `
            -Enabled $true `
            -ErrorAction Stop

        if ($WhatIfPreference) {
            Write-Log "DRYRUN: Would create $sam ($($user.FirstName) $($user.LastName))"
        }
        else {
            Write-Log "SUCCESS: Created $sam ($($user.FirstName) $($user.LastName))"
        }
    }
    catch {
        Write-Log "FAILED: $sam — $_"
    }
}

Write-Log "=== Run finished ==="