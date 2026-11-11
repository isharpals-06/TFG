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
$runningBuild = Get-Process -Name 'The Forgotten World' -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $outputFile }
if ($null -ne $runningBuild) {
	throw 'Close the running game before exporting. Windows keeps the active executable locked and the previous build cannot be cleaned up safely.'
}
$tempBase = (Resolve-Path -LiteralPath $env:TEMP).Path
$tempRoot = Join-Path $tempBase ("forgotten-world-export-" + [Guid]::NewGuid().ToString('N'))
$exportProject = Join-Path $tempRoot 'project'
$exportDirectory = Join-Path $exportProject 'build'
$stagingFile = Join-Path $exportDirectory 'The Forgotten World.exe'
New-Item -ItemType Directory -Force -Path $exportProject | Out-Null

# Export an isolated project copy so an editor window already open on the working tree
# cannot intercept the command or leave the old executable beside an unfinished .tmp.
$null = & robocopy $projectRoot $exportProject /E /XD '.git' '.godot' 'build' 'Godot_v4.7.2-stable_win64.exe' /NFL /NDL /NJH /NJS /NC /NS /NP
$copyExitCode = $LASTEXITCODE
if ($copyExitCode -ge 8) {
	throw "Could not prepare the isolated export copy (robocopy exit code $copyExitCode)."
}
New-Item -ItemType Directory -Force -Path $exportDirectory | Out-Null

$stdoutFile = Join-Path $tempRoot 'godot-export-stdout.log'
$stderrFile = Join-Path $tempRoot 'godot-export-stderr.log'
$argumentLine = '--headless --quiet --path "{0}" --export-release "Windows Desktop" "{1}"' -f $exportProject, $stagingFile
$exportProcess = Start-Process -FilePath $godotPath -ArgumentList $argumentLine -WorkingDirectory $exportProject -Wait -PassThru -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile
$exportExitCode = $exportProcess.ExitCode
$engineOutput = @()
if (Test-Path -LiteralPath $stdoutFile) { $engineOutput += Get-Content -LiteralPath $stdoutFile }
if (Test-Path -LiteralPath $stderrFile) { $engineOutput += Get-Content -LiteralPath $stderrFile }
if ($engineOutput) { $engineOutput | ForEach-Object { Write-Output $_ } }
if (($engineOutput | Out-String) -match '(?i)SCRIPT ERROR|Parse Error|Failed to load script|Failed to create an autoload|ERROR:') {
	throw "Godot reported a script, resource, or export error. The isolated copy is at $tempRoot"
}
if ($exportExitCode -ne 0) {
	throw "Godot export did not return a successful exit code. The isolated copy is at $tempRoot"
}
if (-not (Test-Path -LiteralPath $stagingFile)) {
	throw "Godot did not produce the staged Windows executable. The isolated copy is at $tempRoot"
}

$previousHash = ''
$previousLength = -1L
$stableReadCount = 0
$hash = ''
for ($attempt = 0; $attempt -lt 24; $attempt++) {
	$file = Get-Item -LiteralPath $stagingFile
	$currentHash = (Get-FileHash -LiteralPath $stagingFile -Algorithm SHA256).Hash.ToLowerInvariant()
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
	throw "The staged export did not settle to a stable SHA-256 hash. The existing build was left untouched."
}

$stagedLength = (Get-Item -LiteralPath $stagingFile).Length
$backupFile = Join-Path $tempRoot 'previous-build.exe'
if (Test-Path -LiteralPath $outputFile) {
	[System.IO.File]::Replace($stagingFile, $outputFile, $backupFile)
} else {
	Move-Item -LiteralPath $stagingFile -Destination $outputFile
}
$finalFile = Get-Item -LiteralPath $outputFile
$finalHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
if ($finalFile.Length -ne $stagedLength -or $finalHash -ne $hash) {
	throw "The staged export did not replace the build cleanly."
}
if (Test-Path -LiteralPath $backupFile) { Remove-Item -LiteralPath $backupFile -Force }

$assetImportRoot = Join-Path $exportProject 'design\assets'
$projectAssetRoot = Join-Path $projectRoot 'design\assets'
foreach ($importFile in Get-ChildItem -LiteralPath $assetImportRoot -Filter '*.import' -File -Recurse) {
	$projectImportFile = Join-Path $projectAssetRoot $importFile.Name
	if (-not (Test-Path -LiteralPath $projectImportFile)) {
		Copy-Item -LiteralPath $importFile.FullName -Destination $projectImportFile
	}
}

$staleGodotOutput = Join-Path $outputDirectory 'The Forgotten World.tmp'
if (Test-Path -LiteralPath $staleGodotOutput) { Remove-Item -LiteralPath $staleGodotOutput -Force }
Set-Content -LiteralPath (Join-Path $outputDirectory 'SHA256SUMS.txt') -Value "$hash  The Forgotten World.exe" -Encoding ascii

$resolvedTempRoot = (Resolve-Path -LiteralPath $tempRoot).Path
if ((Split-Path -Parent $resolvedTempRoot) -ne $tempBase -or -not (Split-Path -Leaf $resolvedTempRoot).StartsWith('forgotten-world-export-')) {
	throw "Refusing to remove an export directory outside the temporary folder: $resolvedTempRoot"
}
Remove-Item -LiteralPath $resolvedTempRoot -Recurse -Force
Write-Output "Windows build created: $outputFile"
Write-Output "SHA-256: $hash"
