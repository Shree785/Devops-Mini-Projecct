$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$crumbRes = Invoke-RestMethod -Uri "http://localhost:8081/crumbIssuer/api/xml" -WebSession $session
$crumbField = $crumbRes.defaultCrumbIssuer.crumbRequestField
$crumb = $crumbRes.defaultCrumbIssuer.crumb
Write-Host "Crumb retrieved: $crumbField = $crumb"

$headers = @{}
$headers.Add($crumbField, $crumb)
$headers.Add("Content-Type", "application/xml")

$xml = Get-Content -Raw -Path "D:\ASSIGNMENTS\DEVOPS\DEVOPS PROJECT\Security-Log-Review-Pipeline.xml"
$res = Invoke-WebRequest -Uri "http://localhost:8081/createItem?name=Security-Log-Review-Pipeline" -Method Post -Headers $headers -Body $xml -WebSession $session
Write-Host "Create Item Status: $($res.StatusCode)"

# Now trigger build #1!
$buildRes = Invoke-WebRequest -Uri "http://localhost:8081/job/Security-Log-Review-Pipeline/build" -Method Post -Headers $headers -WebSession $session
Write-Host "Trigger Build Status: $($buildRes.StatusCode)"
