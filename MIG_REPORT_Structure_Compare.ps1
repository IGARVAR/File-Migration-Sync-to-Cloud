<#
.SYNOPSIS
    Compares folder and file structure between two directories.

.DESCRIPTION
    Recursively scans the source and target directories and compares file/folder presence, sizes, and last modified dates.
    Outputs a CSV report of missing, mismatched, or identical objects.

.PARAMETER SourcePath
    Local source directory path (e.g., "C:\Local\HR")

.PARAMETER TargetPath
    Target directory path (e.g., "Z:\SharePoint\HR")

.PARAMETER ReportPath
    Path to save the output CSV file (e.g., "C:\Reports\Compare_Report.csv")

.NOTES
    Author: Ivan Garkusha
    Last Updated: 2025-06
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $true)]
    [string]$TargetPath,

    [Parameter(Mandatory = $true)]
    [string]$ReportPath
)

Write-Host "Comparing structure between:" -ForegroundColor Cyan
Write-Host "Source: $SourcePath"
Write-Host "Target: $TargetPath"

function Get-Structure {
    param (
        [string]$BasePath
    )

    $structure = @()

    Get-ChildItem -Path $BasePath -Recurse -Force | ForEach-Object {
        $relativePath = $_.FullName.Substring($BasePath.Length).TrimStart('\')
        $structure += [PSCustomObject]@{
            ObjectType = if ($_.PSIsContainer) { "Folder" } else { "File" }
            RelativePath = $relativePath
            Size = if ($_.PSIsContainer) { $null } else { $_.Length }
            LastWriteTime = $_.LastWriteTime
        }
    }

    return $structure
}

$sourceItems = Get-Structure -BasePath $SourcePath
$targetItems = Get-Structure -BasePath $TargetPath

# Index for lookup
$targetMap = @{}
foreach ($item in $targetItems) {
    $targetMap[$item.RelativePath.ToLower()] = $item
}

$report = foreach ($src in $sourceItems) {
    $relPath = $src.RelativePath.ToLower()
    $match = $targetMap[$relPath]

    [PSCustomObject]@{
        ObjectType        = $src.ObjectType
        RelativePath      = $src.RelativePath
        ExistsInSource    = $true
        ExistsInTarget    = if ($match) { $true } else { $false }
        SizeMatch         = if ($match -and $src.ObjectType -eq "File") {
                                $src.Size -eq $match.Size
                            } elseif ($src.ObjectType -eq "Folder") {
                                $null
                            } else {
                                $false
                            }
        DateMatch         = if ($match) {
                                $src.LastWriteTime -eq $match.LastWriteTime
                            } else {
                                $false
                            }
    }
}

# Add items that only exist in Target
$sourcePaths = $sourceItems.RelativePath | ForEach-Object { $_.ToLower() }
$extraTargets = $targetItems | Where-Object { $_.RelativePath.ToLower() -notin $sourcePaths }

foreach ($tgt in $extraTargets) {
    $report += [PSCustomObject]@{
        ObjectType        = $tgt.ObjectType
        RelativePath      = $tgt.RelativePath
        ExistsInSource    = $false
        ExistsInTarget    = $true
        SizeMatch         = $null
        DateMatch         = $null
    }
}

# Export report
$report | Sort-Object RelativePath | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
Write-Host "Report saved to: $ReportPath" -ForegroundColor Green
