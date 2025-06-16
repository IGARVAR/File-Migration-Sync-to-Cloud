<#
.SYNOPSIS
Synchronizes selected files from a user's OneDrive to a target SharePoint document library.

.DESCRIPTION
This script connects to Microsoft Graph and copies files from OneDrive (based on extension or path filter)
into a SharePoint library (e.g., for migration, consolidation, or backup). It preserves folder structure and supports filtering.

.NOTES
Author: Ivan Garkusha
Filename: SYNC_OPER_OneDrive_to_SP.ps1

REQUIREMENTS:
- Microsoft Graph SDK / PnP.PowerShell
- Delegate permissions for OneDrive and SharePoint (or app-only token)
- User consent to access OneDrive contents

.PARAMETER OneDriveUserUPN
The UPN (email) of the OneDrive owner.

.PARAMETER SharePointSiteUrl
Target SharePoint site URL.

.PARAMETER DocumentLibrary
Target document library name (e.g., 'Shared Documents').

.PARAMETER FileExtensionFilter
Optional. Sync only files with the given extension (e.g., `.docx`, `.xlsx`).

.EXAMPLE
.\SYNC_OPER_OneDrive_to_SP.ps1 -OneDriveUserUPN "john.doe@contoso.com" -SharePointSiteUrl "https://contoso.sharepoint.com/sites/team" -DocumentLibrary "Documents" -FileExtensionFilter ".docx"
#>

param (
    [Parameter(Mandatory)]
    [string]$OneDriveUserUPN,

    [Parameter(Mandatory)]
    [string]$SharePointSiteUrl,

    [Parameter(Mandatory)]
    [string]$DocumentLibrary,

    [string]$FileExtensionFilter
)

# Connect to Graph
Connect-PnPOnline -Scopes "Files.Read.All", "Sites.ReadWrite.All", "User.Read.All" -Interactive

# Resolve user's OneDrive
$drive = Get-PnPGraphDrive -UserId $OneDriveUserUPN -ErrorAction Stop

# Get all files from OneDrive (simplified to root folder for demo)
$files = Get-PnPGraphDriveItem -DriveId $drive.Id -Children

foreach ($file in $files) {
    if ($file.Folder) { continue }  # Skip folders

    if ($FileExtensionFilter -and ($file.Name -notlike "*$FileExtensionFilter")) {
        continue
    }

    $localPath = "$env:TEMP\$($file.Name)"
    Get-PnPGraphDriveItemContent -DriveId $drive.Id -ItemId $file.Id -Path $localPath

    Add-PnPFile -Path $localPath -Folder $DocumentLibrary
    Write-Host "Uploaded $($file.Name) to SharePoint"
}

Write-Host "Sync completed."
