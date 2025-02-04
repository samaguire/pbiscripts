﻿#Requires -Modules @{ ModuleName="MicrosoftPowerBIMgmt"; ModuleVersion="1.2.1026" }

# This script requires you to authenticate with a Power BI Admin account

param(        
    # {workspaceId}/{reportId}
    $oldDataSet =          "8d820de8-53a6-4531-885d-20b27c85f413/80ab741f-bcfe-44bb-8dd8-61505af01024" # Dataset B  
    ,
    $newDataSet =  "8d820de8-53a6-4531-885d-20b27c85f413/bfe8d5c8-a153-4695-b732-ab7db23580d3" # DataSet A
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "SilentlyContinue"

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition -Parent)

$oldWorkspaceId = (Split-Path $oldDataSet -Parent)
$oldDataSetId = (Split-Path $oldDataSet -Leaf)

$newWorkspaceId = (Split-Path $newDataSet -Parent)
$newDataSetId = (Split-Path $newDataSet -Leaf)

if (!$newWorkspaceId -or !$newDataSetId)
{
    throw "Cannot solve New DataSet Id's"
}

if (!$oldWorkspaceId -or !$oldDataSetId)
{
    throw "Cannot solve Old DataSet Id's"
}

Connect-PowerBIServiceAccount

$workspaces  = Get-PowerBIWorkspace -Scope Organization -All -Include @("reports", "datasets")

$reportDataSetRelationship = $workspaces |%{
    $workspace = $_
    
    $workspace.reports |% {
        
        $report = $_

        Write-Output @{
            workspaceId = $workspace.id
            ;
            workspaceType = $workspace.type
            ;
            reportId = $report.id
            ;
            datasetId = $report.datasetId
        }   
    }    
} 

$oldDataSetRelatedReports = $reportDataSetRelationship |? datasetId -eq $oldDataSetId

if ($oldDataSetRelatedReports.Count -eq 0)
{
    Write-Warning "No reports connected to dataset '$oldDataSetId'"
}

foreach ($report in $oldDataSetRelatedReports)
{
    $reportId = $report.ReportId
    $workspaceId = $report.WorkspaceId
   
    $bodyStr = @{datasetId = $newDataSetId} | ConvertTo-Json

    # If is a personal workspace, workspaceid must be null on rebind

    if ($report.WorkspaceType -eq "PersonalGroup")
    {
        $workspaceId = $null
    }

    Write-Host "Rebinding report '$workspaceId/$reportId' to new dataset '$newDataSetId'"
    
    if ($workspaceId)
    {
        $apiUrl = "groups/$workspaceId/reports/$reportId/Rebind"       
    }
    else
    {
        $apiUrl = "reports/$reportId/Rebind"       
    }

    Invoke-PowerBIRestMethod -Url $apiUrl -method Post -body $bodyStr -ErrorAction Continue
}

