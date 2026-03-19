param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    [string]$Notes = "Updated research triggers for Project Quarm."
)

$JsonFiles = @("CasterResearch.json", "BeastlordTwilight.json")
$GzFiles = @()

Write-Host "--- Starting Release Process for $Version ---" -ForegroundColor Cyan

# Step 1: Compress JSON files into GZIP format (EQLP requirement)
foreach ($JsonFile in $JsonFiles) {
    $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($JsonFile)
    $GzFile = "$BaseName.tgf.gz"
    
    Write-Host "Compressing $JsonFile..."
    $input = [System.IO.File]::OpenRead((Join-Path $PSScriptRoot $JsonFile))
    $output = [System.IO.File]::Create((Join-Path $PSScriptRoot $GzFile))
    $gzipStream = New-Object System.IO.Compression.GZipStream($output, [System.IO.Compression.CompressionMode]::Compress)
    $input.CopyTo($gzipStream)
    $gzipStream.Close()
    $output.Close()
    $input.Close()
    Write-Host "Success: Created $GzFile" -ForegroundColor Green
    $GzFiles += $GzFile
}

# Step 2: Use GitHub CLI to create the release and upload the assets
Write-Host "Uploading to GitHub Releases..."
$ReleaseArgs = @($Version) + $GzFiles + @("--title", "Release $Version", "--notes", $Notes)
gh release create $ReleaseArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "--- Release $Version is LIVE! ---" -ForegroundColor Cyan
} else {
    Write-Host "Error: Release failed. Check your GitHub CLI login." -ForegroundColor Red
}
