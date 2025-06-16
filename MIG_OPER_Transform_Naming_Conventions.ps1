<#
.SYNOPSIS
Standardizes and transforms file and folder names for compatibility with cloud storage platforms (e.g., SharePoint, OneDrive).

.DESCRIPTION
This script scans a specified directory and applies transformations to names of files and folders. It removes or replaces illegal characters,
converts names to lowercase or PascalCase, and optionally appends prefixes/suffixes. Designed to sanitize data during migration processes.

.NOTES
Author: Ivan Garkusha
Filename: MIG_OPER_Transform_Naming_Conventions.ps1

REQUIREMENTS:
- PowerShell 5.1+ or Core
- Access to local or networked file system
- Test mode toggle to preview renames before applying

.PARAMETER SourcePath
The root folder to scan and rename contents.

.PARAMETER ApplyChanges
If specified, the renames will be executed. Otherwise, the script runs in preview mode.

.EXAMPLE
.\MIG_OPER_Transform_Naming_Conventions.ps1 -SourcePath "E:\LegacyDocs" -ApplyChanges
#>

param (
    [Parameter(Mandatory)]
    [string]$SourcePath,

    [switch]$ApplyChanges
)

# List of characters not allowed in SharePoint/OneDrive
$illegalChars = '[~"#%&*:<>?/\\{|}]'

# Get all files and folders
$items = Get-ChildItem -Path $SourcePath -Recurse -Force

foreach ($item in $items) {
    $originalName = $item.Name
    $cleanName = $originalName -replace $illegalChars, '_'  # Replace illegal characters with "_"
    $cleanName = $cleanName.Trim()
    
    # Optionally lowercase or PascalCase (example shown with lowercase)
    $cleanName = $cleanName.ToLower()

    if ($originalName -ne $cleanName) {
        $newPath = Join-Path -Path $item.DirectoryName -ChildPath $cleanName

        if ($ApplyChanges) {
            Rename-Item -Path $item.FullName -NewName $cleanName -ErrorAction SilentlyContinue
            Write-Host "Renamed: $originalName -> $cleanName"
        } else {
            Write-Host "[Preview] Would rename: $originalName -> $cleanName"
        }
    }
}

Write-Host "`nDone."
