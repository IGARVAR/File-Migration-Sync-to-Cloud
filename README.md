# File-Migration-Sync-to-Cloud

**Data migration and sync automation from on-prem to cloud (SharePoint, OneDrive, Teams).**  
Scripts focused on audit, structure alignment, metadata cleanup, and upload automation for hybrid or cloud-first environments.

Can be used as pre-ingestion audit for Copilot/LLM readiness validation
Here’s what I use when helping orgs move 100k files from on-prem to M365, while cleaning and aligning naming, structure, and metadata.
Used in multi-tenant migration across 450 GB of content in different business units
---

## Overview

This repository includes PowerShell-based tools designed to:

- Audit folder/file structure prior to migration
- Filter and normalize filenames for SharePoint/Teams compatibility
- Upload batches of files to SharePoint libraries
- Compare source and destination structures
- Sync user OneDrive folders into Teams or SharePoint
- Prepare naming conventions for cloud readiness

---

## File Index

| Script                                    | Purpose                                                                |
|-------------------------------------------|------------------------------------------------------------------------|
| `MIG_OPER_Copy_OnlyTxt_ByFolder.ps1`      | Recursively copies only `.txt` files into a flat destination structure |
| `MIG_REPORT_Structure_Compare.ps1`        | Compares folder/file structure between source and target paths         |
| `MIG_OPER_SharePoint_BatchUpload.ps1`     | Uploads files from a local folder to SharePoint document library       |
| `SYNC_OPER_OneDrive_to_SP.ps1`            | Migrates user OneDrive folders to a mapped SharePoint site             |
| `MIG_OPER_Transform_Naming_Conventions.ps1` | Normalizes file/folder names to cloud-compatible standards           |

---

## Requirements

- PowerShell 5.1+
- PnP.PowerShell module (for SharePoint)
- Microsoft Graph SDK (for OneDrive)
- Access to SharePoint Online / OneDrive tenant
- Required permissions to upload, read, and write files

---

## Input Data

Some scripts require structured CSV inputs. Example:

```csv
SourcePath, TargetPath
C:\Data\Project1, https://contoso.sharepoint.com/sites/TeamDocs/Shared%20Documents/Project1
