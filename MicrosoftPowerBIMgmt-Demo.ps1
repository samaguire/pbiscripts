#Requires -Modules @{ ModuleName="MicrosoftPowerBIMgmt"; ModuleVersion="1.2.1026" }

# Authentication Prompt
Connect-PowerBIServiceAccount

#region Service Principal
$appId = ""
$tenantId = ""
$appSecret = ""
#$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $appId, ($appSecret | ConvertTo-SecureString -AsPlainText -Force)
#Disconnect-PowerBIServiceAccount
#Connect-PowerBIServiceAccount -ServicePrincipal -Tenant $tenantId -Credential $credential
#endregion

# https://docs.microsoft.com/en-us/powershell/module/microsoftpowerbimgmt.workspaces/get-powerbiworkspace?view=powerbi-ps
$workspaces = Get-PowerBIWorkspace -All
$workspaces | Format-Table
$workspaces.Count

$workspacesAsAdmin = Get-PowerBIWorkspace -Scope Organization -All
$workspacesAsAdmin | Format-Table
$workspacesAsAdmin.Count

# https://docs.microsoft.com/en-us/powershell/module/microsoftpowerbimgmt.data/get-powerbidataset?view=powerbi-ps
$workspaceDatasets = Get-PowerBIDataset -WorkspaceId "1eb4ce83-58cb-4360-8ac5-b7930e81360a"
$workspaceDatasets
$workspaceDatasets.Count

$workspaceDatasets = Get-PowerBIDataset -WorkspaceId "8d820de8-53a6-4531-885d-20b27c85f413"
$workspaceDatasets
$workspaceDatasets.Count

# RAW API Call - https://docs.microsoft.com/en-us/powershell/module/microsoftpowerbimgmt.profile/invoke-powerbirestmethod?view=powerbi-ps
# https://app.powerbi.com/groups/1eb4ce83-58cb-4360-8ac5-b7930e81360a/list
$workspaceDatasets = Invoke-PowerBIRestMethod -Url "groups/1eb4ce83-58cb-4360-8ac5-b7930e81360a/datasets" -Method Get | ConvertFrom-Json | select -ExpandProperty value
$workspaceDatasets
$workspaceDatasets.Count
