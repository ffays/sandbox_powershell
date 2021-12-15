# Run as administrator
$ErrorActionPreference = 'Stop'

# Create User "demo1"
$password1 = Read-Host -AsSecureString
New-LocalUser "demo1" -Password $password1 -FullName "Demo1"
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "demo1"

# Download Zip file
$downloadsFolder = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\').'{374DE290-123F-4565-9164-39C4925E467B}'
$applicationZipName = 'my-application.zip'
$applicationZipPath = "$downloadsFolder\$applicationZipName"
Invoke-WebRequest -Uri "http://example.com/$applicationZipName" -OutFile $applicationZipPath

# Deploy to Program Files
Add-Type -A 'System.IO.Compression.FileSystem'
[IO.Compression.ZipFile]::ExtractToDirectory($applicationZip , $env:ProgramFiles)

# Create shortcut icon
$publicDesktopPath = [Environment]::GetFolderPath('CommonDesktopDirectory')
$shortcutPath = Join-Path -Path $publicDesktopPath 'My Application.lnk'
$applicationFolder = Join-Path -Path $env:ProgramFiles 'my-application'
$applicationExePath = Join-Path -Path $applicationFolder 'my-application.exe'
$ws = New-Object -ComObject WScript.Shell
$shortcut = $ws.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $applicationExePath
$shortcut.Description = 'My Application'
$shortcut.WorkingDirectory = $applicationFolder
$shortcut.WindowStyle = 1 # Normal
$shortcut.Save()

# Fix permissions
$acl = Get-Acl $applicationFolder
$inheritFlag = @([System.Security.AccessControl.InheritanceFlags]::ContainerInherit,[System.Security.AccessControl.InheritanceFlags]::ObjectInherit)
$propagationFlag = [System.Security.AccessControl.PropagationFlags]::None
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ('Users','FullControl',$inheritFlag,$propagationFlag,'Allow')
$acl.AddAccessRule($accessRule)
$acl | Set-Acl $applicationFolder

# Set Time Zone
Set-TimeZone -Id "Romance Standard Time" -PassThru
