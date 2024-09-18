$currentDirectory = Get-Location

if (-not (Get-Module -ListAvailable -Name PS2EXE)) {
    Write-Host "PS2EXE not found. Installing PS2EXE module..."
    Install-Module -Name PS2EXE -Force
}

$inputFile = Join-Path $currentDirectory "process_timer.ps1"
$outputFile = Join-Path $currentDirectory "process_timer.exe"
$iconFile = Join-Path $currentDirectory "icon.ico"

Write-Host "Compiling $inputFile to $outputFile..."

if (Test-Path $iconFile) {
    ps2exe -inputFile $inputFile -outputFile $outputFile -noConsole -iconFile $iconFile
} else {
    ps2exe -inputFile $inputFile -outputFile $outputFile -noConsole
}

Write-Host "Compilation completed. EXE created at $outputFile."
