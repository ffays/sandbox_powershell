# Run [as adminstrator|elevated]
# Article: https://stackoverflow.com/questions/22233702/how-to-download-the-ssl-certificate-from-a-website-using-powershell

$ErrorActionPreference = "Stop"

function Import-Cert-In-Java-Truststore {
    param ( 
        [Uri]$uri 
    )
    $jdkRegistryPath = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Development Kit'
    $jdkVersion = Get-ItemPropertyValue -Path $jdkRegistryPath -Name CurrentVersion
    $javaHome = Get-ItemPropertyValue -Path "${jdkRegistryPath}\$jdkVersion" -Name JavaHome

    $request = [System.Net.HttpWebRequest]::Create($uri)
    try { $request.GetResponse().Dispose() } catch { if ($_.Exception.Status -ne [System.Net.WebExceptionStatus]::TrustFailure) {throw} }
    $tempFile = [System.IO.Path]::GetTempFileName()

@"
-----BEGIN CERTIFICATE-----
$([System.Convert]::ToBase64String($request.ServicePoint.Certificate.GetRawCertData()) -replace '(.{64})',"`$1`n")
-----END CERTIFICATE-----
"@ | Out-File -Encoding ascii -FilePath $tempFile -NoNewline


    & $javaHome\bin\keytool.exe -importcert -file $tempFile -alias $request.Host -keystore $javaHome\jre\lib\security\cacerts -storepass changeit -noprompt

    Remove-Item $tempFile
}

Import-Cert-In-Java-Truststore -uri https://services.gradle.org/
