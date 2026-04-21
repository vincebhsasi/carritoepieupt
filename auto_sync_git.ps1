param(
    [int]$IntervalSeconds = 8,
    [int]$QuietSeconds = 30,
    [int]$MinCommitSeconds = 120,
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

function Get-StatusFingerprint {
    $status = git status --porcelain
    if ([string]::IsNullOrWhiteSpace($status)) {
        return ""
    }

    return ($status -split "`n" | ForEach-Object { $_.Trim() } | Sort-Object) -join "|"
}

if (-not (Ensure-GitIdentity)) {
    exit 1
}

if ($IntervalSeconds -lt 2) {
    Write-Host "IntervalSeconds muy bajo. Usa 2 o mayor." -ForegroundColor Yellow
    exit 1
}

if ($QuietSeconds -lt $IntervalSeconds) {
    Write-Host "QuietSeconds debe ser mayor o igual a IntervalSeconds." -ForegroundColor Yellow
    exit 1
}

if ($MinCommitSeconds -lt $QuietSeconds) {
    Write-Host "MinCommitSeconds debe ser mayor o igual a QuietSeconds." -ForegroundColor Yellow
    exit 1
}

Write-Info "Auto sync iniciado. Intervalo: $IntervalSeconds s. Calma: $QuietSeconds s. Min commit: $MinCommitSeconds s. Rama: $Branch"
Write-Info "Presiona Ctrl+C para detener."

$lastFingerprint = ""
$lastChangeAt = $null
$lastCommitAt = (Get-Date).AddYears(-1)

while ($true) {
    try {
        if (Has-MergeConflicts) {
            Write-Info "Hay conflictos de merge. Auto-sync en pausa."
            Start-Sleep -Seconds $IntervalSeconds
            continue
        }

        $fingerprint = Get-StatusFingerprint

        if ([string]::IsNullOrWhiteSpace($fingerprint)) {
            $lastFingerprint = ""
            $lastChangeAt = $null
            Start-Sleep -Seconds $IntervalSeconds
            continue
        }

        if ($fingerprint -ne $lastFingerprint) {
            $lastFingerprint = $fingerprint
            $lastChangeAt = Get-Date
            Start-Sleep -Seconds $IntervalSeconds
            continue
        }

        $now = Get-Date
        $quietElapsed = ($now - $lastChangeAt).TotalSeconds
        $sinceLastCommit = ($now - $lastCommitAt).TotalSeconds

        if ($quietElapsed -ge $QuietSeconds -and $sinceLastCommit -ge $MinCommitSeconds) {
            git add -A | Out-Null

            $pendingAfterAdd = git diff --cached --name-only
            if (-not [string]::IsNullOrWhiteSpace($pendingAfterAdd)) {
                $msg = "auto-sync: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                git commit -m $msg | Out-Null
                git push origin $Branch | Out-Null
                $lastCommitAt = Get-Date
                Write-Info "Cambios subidos a origin/$Branch"
            }
        }
    }
    catch {
        Write-Info ("Error: " + $_.Exception.Message)
    }

    Start-Sleep -Seconds $IntervalSeconds
}
