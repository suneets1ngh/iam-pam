<#-------------------------------------------------------#>
<# Delinea Health & Component Staus Emailing Script v2.0 #>
<#-------------------------------------------------------#>


<#----------------Authentication Block-------------------#>

$authbody = @{
    grant_type    = "client_credentials"
    scope         = "xpmheadless"
    client_id     = "[USERNAME]"
    client_secret = "[PASSWORD]"
}

$authenticateRequest = Invoke-RestMethod `
    -Uri "https://[yourplatform].delinea.app/identity/api/oauth2/token/xpmplatform" `
    -Method Post `
    -ContentType "application/x-www-form-urlencoded" `
    -Body $authbody

$authenticateRequest


$headers = @{
"Authorization" = "Bearer $($authenticateRequest.access_token)" 
"Accept-Language" = "en"
"Accept" = "application/json, text/plain, */*"
}

<#-------------------------------------------------------#>
 

<#------------------Platform Connectors------------------#>
$body = @{
Args = @{
Caching = -1
Limit = 100000
PageNumber = 1
PageSize = 100000
SortBy = ""
}
} | ConvertTo-Json
 
$response = Invoke-WebRequest `
-Uri "https://[your Delinea platform URL]/identity/api/core/GetProxies" `
-Method Post `
-Headers $headers `
-Body $body `
-ContentType "application/json"
 
#$response.StatusCode
#$response.Headers
#$body = $response.Content

#echo $body
$listed = $response.Content | ConvertFrom-Json

$connectorList = foreach ($connector in $listed.Result) {
[PSCustomObject]@{
Name = $connector.Name
Machine = $connector.MachineName
Domain = $connector.Domain
Online = $connector.Online
Version = $connector.Version
}
}


#echo " `n --------connectors---------------"
#echo $connectorList `n`n
echo "-----------------------"
<#-------------------------------------------------------#>


<#-----------------Platform Engines----------------------#>
$body1 = @{
siteIds = @()
includeGroups = $true
page = @{
take = 100
skip = 0
getTotalCount = $true
}
primaryFunction = "engine"
} | ConvertTo-Json
 
$platformengines = Invoke-RestMethod `
-Uri "https://[your Delinea platform URL]/engine-pool/api/engines/search" `
-Method Post `
-Headers $headers `
-Body $body1 `
-ContentType "application/json"

$engineList = foreach ($engine in $platformengines.engines) {
[PSCustomObject]@{
Name = $engine.Name
Machine = $engine.MachineName
Group = $engine.groups.name
Status = $engine.displayState
Version = $engine.engineLabels.'engine.version'
}
}
 
#echo $engineList
#echo $engineList `n`n
echo "-----------------------`n"
<#-------------------------------------------------------#>



<#---------------------Distributed Engine----------------#>
$deSite = @(
    "2"
    "4"
    "6"
    "7"
)

$dengineList = [System.Collections.Generic.List[object]]::new() 

foreach ($siteID in $deSite) {
$de = Invoke-RestMethod `
-Uri "https://[YOUR Delinea Secret Server Domain]/api/v1/distributed-engine/engines?filter.onlyIncludeRequiringAction=false&filter.siteId=$siteID&skip=0&sortBy%5B0%5D.direction=Asc&sortBy%5B0%5D.name=friendlyName&take=60" `
-Method Get `
-Headers $headers
 
#$de.records


foreach ($dengine in $de.records) {
$dengineList.Add(
[PSCustomObject]@{
Name = $dengine.hostName
Status = $dengine.connectionStatus
Version = $dengine.currentVersion
latestVersion = $dengine.latestVersion
}
)
}
}
echo $dengineList
echo "-----------------------"
<#-------------------------------------------------------#>


<#------------------Email------------------------#>
<#data collate#>

$onlineConnectors  = ($connectorList | Where-Object {$_.Online -eq $true}).Count
$offlineConnectors = ($connectorList | Where-Object {$_.Online -ne $true}).Count

$onlineEngines  = ($engineList | Where-Object {$_.Status -match 'Online|Connected|Running'}).Count
$offlineEngines = $engineList.Count - $onlineEngines

$connectedDE  = ($dengineList | Where-Object {$_.Status -eq 'Connected'}).Count
$disconnectedDE = $dengineList.Count - $connectedDE

$connectorRows = foreach ($item in $connectorList) {

    $statusColor = if($item.Online){
        "#28a745"
    }
    else{
        "#dc3545"
    }

@"
<tr>
    <td>$($item.Name)</td>
    <td>$($item.Machine)</td>
    <td>$($item.Domain)</td>
    <td style='color:white;background:$statusColor;font-weight:bold;text-align:center'>
        $($item.Online)
    </td>
    <td>$($item.Version)</td>
</tr>
"@
}

$engineRows = foreach ($item in $engineList) {

    $statusColor = if($item.Status -match "Online|Connected|Running"){
        "#28a745"
    }
    else{
        "#dc3545"
    }

@"
<tr>
    <td>$($item.Name)</td>
    <td>$($item.Machine)</td>
    <td>$($item.Group)</td>
    <td style='color:white;background:$statusColor;font-weight:bold;text-align:center'>
        $($item.Status)
    </td>
    <td>$($item.Version)</td>
</tr>
"@
}

$dengineRows = foreach ($item in $dengineList) {

    if($item.Status -eq "Online"){
        $statusColor = "#28a745"
    }
    else{
        $statusColor = "#dc3545"
    }

    if($item.Version -ne $item.latestVersion){
        $versionColor = "#ffc107"
    }
    else{
        $versionColor = "#28a745"
    }

@"
<tr>
    <td>$($item.Name)</td>
    <td style='color:white;background:$statusColor;font-weight:bold;text-align:center'>
        $($item.Status)
    </td>
    <td style='background:$versionColor;color:black;font-weight:bold'>$($item.Version)</td>
    <td>
        $($item.latestVersion)
    </td>
</tr>
"@
}




$emailBody = @"
<html>
<head>
<style>

body{
    font-family: Segoe UI, Arial, sans-serif;
    background:#f4f6f9;
    margin:0;
    padding:20px;
}

.container{
    max-width:1400px;
    margin:auto;
}

.header{
    background:#003366;
    color:white;
    padding:20px;
    border-radius:10px;
}

.header h1{
    margin:0;
}

.card{
    background:white;
    padding:20px;
    border-radius:10px;
    margin-top:20px;
    box-shadow:0px 2px 10px rgba(0,0,0,.12);
}

.summary{
    display:flex;
    gap:15px;
    margin-top:15px;
}

.summaryBox{
    flex:1;
    text-align:center;
    color:white;
    padding:15px;
    border-radius:8px;
}

.green{
    background:#28a745;
}

.red{
    background:#dc3545;
}

.blue{
    background:#0078D4;
}

table{
    width:100%;
    border-collapse:collapse;
    margin-top:10px;
}

th{
    background:#0078D4;
    color:white;
    padding:10px;
    text-align:left;
}

td{
    border:1px solid #dddddd;
    padding:8px;
}

tr:nth-child(even){
    background:#f7f7f7;
}

.sectionTitle{
    color:#003366;
    font-size:20px;
    font-weight:bold;
    margin-bottom:10px;
}

.footer{
    margin-top:25px;
    text-align:center;
    color:#666;
    font-size:11px;
}

</style>
</head>

<body>

<div class='container'>

<div class='header'>
<h1>Delinea Platform Health Report</h1>
<p>Generated: $(Get-Date -Format "dd-MMM-yyyy HH:mm:ss")</p>
</div>

<div class='summary'>

<div class='summaryBox green'>
<h2>$onlineConnectors</h2>
Connectors Online
</div>

<div class='summaryBox red'>
<h2>$offlineConnectors</h2>
Connectors Offline
</div>

<div class='summaryBox blue'>
<h2>$($connectorList.Count + $engineList.Count + $dengineList.Count)</h2>
Total Components
</div>

</div>

<div class='card'>
<div class='sectionTitle'>Platform Connectors</div>

<table>
<tr>
<th>Name</th>
<th>Machine</th>
<th>Domain</th>
<th>Online?</th>
<th>Version</th>
</tr>

$($connectorRows -join "`n")

</table>

</div>

<div class='card'>
<div class='sectionTitle'>Platform Engines</div>

<table>
<tr>
<th>Name</th>
<th>Machine</th>
<th>Group</th>
<th>Status</th>
<th>Version</th>
</tr>

$($engineRows -join "`n")

</table>

</div>

<div class='card'>
<div class='sectionTitle'>Distributed Engines</div>

<table>
<tr>
<th>Name</th>
<th>Status</th>
<th>Current Version</th>
<th>Latest Version</th>
</tr>

$($dengineRows -join "`n")

</table>

</div>

<div class='footer'>
Delinea Automated Health Check Report
</div>

</div>

</body>
</html>
"@



$payload = @{
    Body    = $emailBody
} | ConvertTo-Json -Depth 5




<#-------------------------------------------------------#>


$response = Invoke-WebRequest `
-Uri "https://XXXX.environment.api.powerplatform.com/powerautomate/automations/direct/cu/07/workflows/YYYY" `
-Method Post `
-Body $payload `
-ContentType "application/json" 

<#-------------------------------------------------------#>

