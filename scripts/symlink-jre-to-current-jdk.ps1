# Execute the next line once from an interactive Powershell session
# Set-ExecutionPolicy RemoteSigned CurrentUser -Force

# Creates a symbolic link "jre" in the current folder to the current JDK
$jdkRegistryPath = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Development Kit'
$jdkVersion = Get-ItemPropertyValue -Path $jdkRegistryPath -Name CurrentVersion
$javaHome = Get-ItemPropertyValue -Path "${jdkRegistryPath}\$jdkVersion" -Name JavaHome
$jreFolderName = "jre"

If($(Test-Path $jreFolderName)) {
    cmd.exe /c rmdir $jreFolderName
} else {
    cmd.exe /c mklink /j $jreFolderName "${javaHome}" | Out-Null
}
