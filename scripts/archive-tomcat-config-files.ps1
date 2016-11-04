Remove-Variable * -ErrorAction SilentlyContinue

$tomcat_home = "C:\Tomcat8"
$webapp = "manager"
$output_dir = "C:\TEMP"

# List of configuration files to be archived
$tomcat_config_files = @(
    "catalina.policy",
    "catalina.properties",
    "context.xml",
    "logging.properties",
    "server.xml",
    "tomcat-users.xml",
    "web.xml"
).GetEnumerator() | % { Join-Path $tomcat_home -ChildPath "conf" | Join-Path -ChildPath $_ }


# Temporary folders and subfolders
$temp_root_name     = $env:COMPUTERNAME + "_config_" + $(Get-Date -format "yyyy-MM-ddTHH.mm.ss")
$temp_root_folder   = Join-Path $output_dir  -ChildPath $temp_root_name
$temp_tomcat_folder = Join-Path $temp_root_folder -ChildPath $([System.IO.Path]::GetFileNameWithoutExtension($tomcat_home))
$temp_conf_folder   = Join-Path $temp_tomcat_folder -ChildPath "conf"
$temp_zip_file      = Join-Path $output_dir  -ChildPath $($temp_root_name + ".zip")

# files with password
$temp_server_xml_file       = Join-Path $temp_conf_folder -ChildPath "server.xml"
$temp_tomcat_users_xml_file = Join-Path $temp_conf_folder -ChildPath "tomcat-users.xml"
$temp_toobox_web_xml_file   = Join-Path $temp_tomcat_folder -ChildPath "webapps\$webapp\WEB-INF\web.xml"

# Creates the temporary folder and subfolders
mkdir $temp_conf_folder | Out-Null
mkdir $(Join-Path $temp_tomcat_folder -ChildPath "webapps\$webapp\WEB-INF" ) | Out-Null

# Copy the configuration files to the temporary folder
$tomcat_config_files | % { Copy-Item -Path $_ -Destination $temp_conf_folder }
Copy-Item $(Join-Path $tomcat_home -ChildPath "webapps\$webapp\WEB-INF\web.xml") $temp_toobox_web_xml_file

# Wipe passwords.
$temp_server_xml = [xml](Get-Content $temp_server_xml_file)
$temp_server_xml.SelectSingleNode("/Server/Service[@name='Catalina']/Connector[@port='8443']/@keystorePass").value = '****'
$temp_server_xml.Save($temp_server_xml_file)

$temp_tomcat_users_xml = [xml](Get-Content $temp_tomcat_users_xml_file)
$temp_tomcat_users_xml.SelectNodes("/tomcat-users/user") | % { $_.SelectSingleNode("@password").value = '****'}
$temp_tomcat_users_xml.Save($temp_tomcat_users_xml_file)

$temp_toobox_web_xml = [xml](Get-Content $temp_toobox_web_xml_file)
$ns = New-Object System.Xml.XmlNamespaceManager($temp_toobox_web_xml.NameTable)
$ns.AddNamespace("ns", $temp_toobox_web_xml.DocumentElement.NamespaceURI)
# $temp_toobox_web_xml.SelectSingleNode("/ns:web-app/ns:context-param/ns:param-name[text()='PASSWORD']/../ns:param-value/text()", $ns).value = '****'
$temp_toobox_web_xml.SelectSingleNode("/ns:web-app/ns:servlet/ns:init-param/ns:param-name[text()='debug']/../ns:param-value/text()", $ns).value = '9'
$temp_toobox_web_xml.Save($temp_toobox_web_xml_file)

# Requires .Net 4.5
# Add-Type -Assembly "System.IO.Compression.FileSystem"
# [System.IO.Compression.ZipFile]::CreateFromDirectory($temp_root_folder, $temp_zip_file)

function create-7zip([String] $folder, [String] $zipFile) {
    [string]$zipExe = "$($Env:ProgramFiles)\7-Zip\7z.exe"
    [Array]$arguments = "a", "-tzip", "$zipFile", "$folder", "-r", "-mx=9"
    & $zipExe $arguments
}

# Zip the temporary folder
create-7zip $temp_tomcat_folder $temp_zip_file | Out-Null
Remove-Item $temp_root_folder -Recurse
Write-Host "Archived:" $temp_zip_file

# List installed .Net versions
# wmic /namespace:\\root\cimv2 path win32_optionalfeature where "caption like '%.NET%'"
# Get-WmiObject win32_optionalfeature  -filter "caption LIKE '%.NET%'" | select Name,Caption,Installstate
# Get-WindowsFeature | Where-Object {$_.DisplayName -like "*.NET*"}
# C:\Windows\Microsoft.NET\Framework
# C:\Windows\Microsoft.NET\Framework64
