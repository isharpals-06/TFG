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
& $godotPath --headless --path $projectRoot --export-release 'Windows Desktop' $outputFile
$exportSucceeded = $?
$exportExitCode = $LASTEXITCODE
if (-not $exportSucceeded -or ($null -ne $exportExitCode -and $exportExitCode -ne 0)) {
	$failureDetail = if ($null -ne $exportExitCode) { " with exit code $exportExitCode" } else { "" }
	throw "Godot export failed$failureDetail."
}

$previousHash = ''
$hash = ''
for ($attempt = 0; $attempt -lt 10; $attempt++) {
	$currentHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
	if ($currentHash -eq $previousHash) {
		$hash = $currentHash
		break
	}
	$previousHash = $currentHash
	Start-Sleep -Milliseconds 200
}
if ([string]::IsNullOrEmpty($hash)) {
	throw "The exported file did not settle to a stable SHA-256 hash."
}
Set-Content -LiteralPath (Join-Path $outputDirectory 'SHA256SUMS.txt') -Value "$hash  The Forgotten World.exe" -Encoding ascii
Write-Output "Windows build created: $outputFile"
Write-Output "SHA-256: $hash"
