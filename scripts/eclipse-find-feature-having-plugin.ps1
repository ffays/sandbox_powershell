$eclipseHome = "${env:USERPROFILE}\eclipse\rcp-oxygen\eclipse"

$lookupValue = 'org.eclipse.jdt'

Get-ChildItem -Recurse "${eclipseHome}\features" ` | Where-Object Name -eq 'feature.xml' `
| % {
    $xml = [xml](Get-Content $_.FullName) 
    $featureId = $xml.SelectSingleNode("/feature/@id").value
    $featureFile = $_.FullName
    $plugins = $xml.SelectNodes("/feature/plugin")
    $pluginIds = $plugins | % {$_.id}
    
    if($pluginIds -contains $lookupValue) {
        Write-Output "${featureId} ${featureFile}"
        #Write-Output $plugins
    }
}
