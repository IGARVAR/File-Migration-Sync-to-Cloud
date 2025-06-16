<#
.SYNOPSIS
Performs batch upload of files to SharePoint document library using PnP.PowerShell.

.DESCRIPTION
This script reads files from a local folder and uploads them to a specified SharePoint Online document library.
It handles folders recursively, logs results, and supports skipping duplicates.

.NOTES
Author: Ivan Garkusha
Filename: MIG_OPER_SharePoint_BatchUpload.ps1

REQUIREMENTS:
- PnP.PowerShell module
- SharePoint Online access with write permissions
- MFA or app-based login via Connect-PnPOnline

.PARAMETER LocalFolder
Local root path from which files will be uploaded.

.PARAMETER TargetSite
SharePoint Online site URL.

.PARAMETER LibraryName
Document library where files will be uploaded.

.PARAMETER SkipIfExists
Optional. Skips uploading files that already exist in the library.

.EXAMPLE
.\MIG_OPER_SharePoint_BatchUpload.ps1 -LocalFolder "C:\Data" -TargetSite "https://contoso.sharepoint.com/sites/migration" -LibraryName "Shared Documents"
#>

param (
    [Parameter(Mandatory)]
    [string]$LocalFolder,

    [Parameter(Mandatory)]
    [string]$TargetSite,

    [Parameter(Mandatory)]
    [string]$LibraryName,

    [switch]$SkipIfExists
)

# Connect to SharePoint
Connect-PnPOnline -Url $TargetSite -Interactive

# Get all files recursively
$files = Get-ChildItem -Path $LocalFolder -Recurse -File

foreach ($file in $files) {
    $relativePath = $file.FullName.Substring($LocalFolder.Length).TrimStart('\')
    $spPath = $relativePath -replace '\\', '/'

    if ($SkipIfExists) {
        $existing = Get-PnPFolderItem -FolderSiteRelativeUrl $LibraryName -ItemName $spPath -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "Skipping existing file: $spPath"
            continue
        }
    }

    Add-PnPFile -Path $file.FullName -Folder $LibraryName/$($spPath | Split-Path -Parent) -ErrorAction Stop
    Write-Host "Uploaded: $spPath"
}

Write-Host "Upload completed."
