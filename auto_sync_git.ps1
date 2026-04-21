param(
    [int]$IntervalSeconds = 8,
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

function Write-Info {
    param([string]$Message)
    $time = Get-Date -Format "HH:mm:ss"
    Write-Host "[$time] $Message"
}

function Ensure-GitIdentity {
    $name = git config user.name
    $email = git config user.email

    if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($email)) {
        Write-Host "Falta configurar identidad de Git en este repo." -ForegroundColor Yellow
        Write-Host "Ejecuta:" -ForegroundColor Yellow
        Write-Host "  git config user.name \"Tu Nombre\"" -ForegroundColor Yellow
        Write-Host "  git config user.email \"tu_correo@ejemplo.com\"" -ForegroundColor Yellow
        return $false
    }

    return $true
}

function Has-MergeConflicts {
    $conflicts = git diff --name-only --diff-filter=U
    return -not [string]::IsNullOrWhiteSpace($conflicts)
}

if (-not (Ensure-GitIdentity)) {
    exit 1
}

Write-Info "Auto sync iniciado. Intervalo: $IntervalSeconds s. Rama: $Branch"
Write-Info "Presiona Ctrl+C para detener."

while ($true) {
    try {
        if (Has-MergeConflicts) {
            Write-Info "Hay conflictos de merge. Auto-sync en pausa."
            Start-Sleep -Seconds $IntervalSeconds
            continue
        }

        $changes = git status --porcelain
        if (-not [string]::IsNullOrWhiteSpace($changes)) {
            git add -A | Out-Null

            $pendingAfterAdd = git diff --cached --name-only
            if (-not [string]::IsNullOrWhiteSpace($pendingAfterAdd)) {
                $msg = "auto-sync: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                git commit -m $msg | Out-Null
                git push origin $Branch | Out-Null
                Write-Info "Cambios subidos a origin/$Branch"
            }
        }
    }
    catch {
        Write-Info ("Error: " + $_.Exception.Message)
    }

    Start-Sleep -Seconds $IntervalSeconds
}
