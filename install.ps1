param(
  [string]$LokiAddr
)

$binDir = "$HOME\bin"
if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir | Out-Null }

if (-not (Test-Path "$binDir\logcli.exe")) {
  Invoke-WebRequest "https://github.com/grafana/loki/releases/latest/download/logcli-windows-amd64.exe.zip" -OutFile "$binDir\logcli.zip"
  Expand-Archive "$binDir\logcli.zip" -DestinationPath $binDir -Force
  Rename-Item "$binDir\logcli-windows-amd64.exe" "logcli.exe" -Force
  Remove-Item "$binDir\logcli.zip"
  Write-Output "Installed logcli to $binDir\logcli.exe"
} else {
  Write-Output "logcli already installed"
}

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$binDir*") {
  [Environment]::SetEnvironmentVariable("Path", "$userPath;$binDir", "User")
  Write-Output "Added $binDir to PATH (needs a new terminal to take effect)"
}

if (-not $LokiAddr) {
  $LokiAddr = Read-Host "Loki address (e.g. https://loki.example.com), or leave blank to set LOKI_ADDR yourself later"
}
if ($LokiAddr) {
  [Environment]::SetEnvironmentVariable("LOKI_ADDR", $LokiAddr, "User")
  Write-Output "LOKI_ADDR set to $LokiAddr"
}

$marker = "# >>> logcli-shortcuts >>>"
$block = @'
# >>> logcli-shortcuts >>>
function Invoke-Loki {
  param([Parameter(Mandatory=$true)][string]$Selector, [Parameter(ValueFromRemainingArguments=$true)][string[]]$Extra)
  $query = $Selector
  if ($PSVersionTable.PSVersion.Major -lt 7) { $query = $query -replace '"', '\"' }
  & logcli.exe query $query @Extra
}
function lt {
  param([Parameter(Mandatory=$true, Position=0)][string]$Selector, [string]$Since = "5m")
  Invoke-Loki $Selector --since=$Since --follow
}
function lg {
  param([Parameter(Mandatory=$true, Position=0)][string]$Term, [Parameter(Mandatory=$true, Position=1)][string]$Selector, [string]$Since = "1h")
  Invoke-Loki "$Selector |= `"$Term`"" --since=$Since
}
# <<< logcli-shortcuts <<<
'@

foreach ($profilePath in @(
  "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
  "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
)) {
  $profileDir = Split-Path $profilePath
  if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
  if (-not (Test-Path $profilePath)) { New-Item -ItemType File -Path $profilePath | Out-Null }
  $existing = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
  if ($existing -notlike "*$marker*") {
    Add-Content -Path $profilePath -Value "`n$block"
    Write-Output "Added logcli shortcuts to $profilePath"
  } else {
    Write-Output "$profilePath already has logcli shortcuts"
  }
}

Write-Output "`nDone. Open a NEW terminal, then test with: logcli labels --since=24h"
Write-Output "If that fails with a DNS lookup error behind a split-DNS VPN, see the README's 'VPN split-DNS gotcha' section."
