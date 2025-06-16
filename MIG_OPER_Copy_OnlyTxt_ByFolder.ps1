<#
.SYNOPSIS
Copies only `.txt` files from a source folder structure to a destination, preserving subfolders.

.DESCRIPTION
This script recursively scans a source directory and copies all `.txt` files to a destination path.
It preserves the folder hierarchy and creates any missing subdirectories.

Useful for file system cleanup, legacy data filtering, or preparing structured data for migration to SharePoint or cloud storage.

.NOTES
Author: Ivan Garkusha
Filename: MIG_OPER_Copy_OnlyTxt_ByFolder.ps1
Date: 2025-06-16

REQUIREMENTS:
- PowerShell 5.1 or Core
- File system access rights

USAGE:
- Set $SourceRoot and $TargetRoot to valid paths.
- Only .txt files will be copied.
- Existing files at the target will be overwritten.

.EXAMPLE
.\MIG_OPER_Copy_OnlyTxt_ByFolder.ps1
#>

# ==== Configuration ====
$SourceRoot = "C:\LegacyData\Projects"
$TargetRoot = "D:\FilteredMigration\TxtOnly"

# ==== Logic ====
Write-Host " Scanning $SourceRoot for .txt files..."

$txtFiles = Get-ChildItem -Path $SourceRoot -Recurse -Filter *.txt -File

foreach ($file in $txtFiles) {
    $relativePath = $file.FullName.Substring($SourceRoot.Length)
    $targetPath = Join-Path $TargetRoot $relativePath
    $targetDir = Split-Path $targetPath

    if (-not (Test-Path $targetDir)) {
        New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
    }

    Copy-Item -Path $file.FullName -Destination $targetPath -Force
    Write-Host " Copied: $($file.FullName) -> $targetPath"
}

Write-Host "`n Completed copying all .txt files."
