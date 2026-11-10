param(
    [string]$GodotExe = (Join-Path $PSScriptRoot '..\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe')
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$godotPath = (Resolve-Path -LiteralPath $GodotExe).Path
$templatePath = Join-Path $env:APPDATA 'Godot\export_templates\4.7.2.stable\windows_release_x86_64.exe'
if (-not (Test-Path -LiteralPath $templatePath)) {
    throw "Godot 4.7.2 Windows x86_64 release template not found at $templatePath. Install it from Editor > Manage Export Templates."
}

$outputDirectory = Join-Path $projectRoot 'build'
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$outputFile = Join-Path $outputDirectory 'The Forgotten World.exe'
$engineOutput = & $godotPath --headless --path $projectRoot --export-release 'Windows Desktop' $outputFile 2>&1
$exportSucceeded = $?
$exportExitCode = $LASTEXITCODE
if ($engineOutput) {
	$engineOutput | ForEach-Object { Write-Output $_ }
}
if (($engineOutput | Out-String) -match '(?i)SCRIPT ERROR|Parse Error|Failed to load script|Failed to create an autoload|ERROR:') {
	throw "Godot reported a script, resource, or export error."
}
if (-not $exportSucceeded -or ($null -ne $exportExitCode -and $exportExitCode -ne 0)) {
	$failureDetail = if ($null -ne $exportExitCode) { " with exit code $exportExitCode" } else { "" }
	throw "Godot export failed$failureDetail."
}

$previousHash = ''
$previousLength = -1L
$stableReadCount = 0
$hash = ''
for ($attempt = 0; $attempt -lt 24; $attempt++) {
	$file = Get-Item -LiteralPath $outputFile
	$currentHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
	if ($currentHash -eq $previousHash -and $file.Length -eq $previousLength) {
		$stableReadCount++
	} else {
		$stableReadCount = 0
	}
	if ($stableReadCount -ge 3) {
		$hash = $currentHash
		break
	}
	$previousHash = $currentHash
	$previousLength = $file.Length
	Start-Sleep -Milliseconds 250
}
if ([string]::IsNullOrEmpty($hash)) {
	throw "The exported file did not settle to a stable SHA-256 hash."
}
Set-Content -LiteralPath (Join-Path $outputDirectory 'SHA256SUMS.txt') -Value "$hash  The Forgotten World.exe" -Encoding ascii
Write-Output "Windows build created: $outputFile"
Write-Output "SHA-256: $hash"
