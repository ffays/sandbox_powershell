# usage: powershell -file ftps.ps1 -login demo -password password -uri ftps://test.rebex.net/pub/example/winceclient.png

param (
   [Parameter(Mandatory=$true)][string]$uri,
   [string]$login,
   [string]$password,
   [int]$timeout = 30,
   [string]$downloadsFolder = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\').'{374DE290-123F-4565-9164-39C4925E467B}',
   [switch]$ignoreCertificateErrors
)

$ErrorActionPreference = "Stop"

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class IDontCarePolicy : ICertificatePolicy {
        public IDontCarePolicy() {}
        public bool CheckValidationResult(ServicePoint sPoint, X509Certificate cert, WebRequest wRequest, int certProb) {
            return true;
        }
    }
"@
if($ignoreCertificateErrors) {
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object IDontCarePolicy
}


$request = [System.Net.FtpWebRequest]::Create($($uri -ireplace "ftps://", "ftp://"))

if(-not (([string]::IsNullOrEmpty($login)) -or ([string]::IsNullOrEmpty($password)))) {
    $request.Credentials = New-Object System.Net.NetworkCredential($login, $password)
}
$request.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
$request.EnableSsl = $uri.StartsWith("ftps", "CurrentCultureIgnoreCase")
$request.UseBinary = $True
$request.UsePassive = $True
$request.KeepAlive = $False
$request.Timeout = $timeout * 1000

$response = $request.GetResponse()
if($response.StatusCode -eq [System.Net.FtpStatusCode]::DataAlreadyOpen -or $response.StatusCode -eq [System.Net.FtpStatusCode]::OpeningData) {
    $responseStream = $response.GetResponseStream()
    $reader = New-Object System.IO.BinaryReader($responseStream)

    $localPath = $response.ResponseUri.LocalPath
    $fileName = [System.IO.Path]::GetFileName($localPath)
    $fileName = Join-Path $downloadsFolder -ChildPath $fileName  

    $writer = [IO.File]::OpenWrite($fileName)
    $buffer = New-Object byte[] 1024

    $bytesRead = $reader.Read($buffer,0,$buffer.Length)
    while($bytesRead -ne 0) {
        $writer.Write($buffer, 0, $bytesRead);
        $bytesRead = $reader.Read($buffer,0,$buffer.Length)
    }

    $writer.Flush()
    $writer.Close()
    Write-Host "Recorded : $fileName"
}

$response.Close()

# https://stackoverflow.com/questions/1279041/powershell-ftpwebrequest-and-enablessl-true
# http://test.rebex.net/
# https://docs.microsoft.com/en-us/dotnet/framework/network-programming/how-to-download-files-with-ftp
# https://docs.microsoft.com/en-us/dotnet/framework/network-programming/how-to-upload-files-with-ftp
# https://blogs.technet.microsoft.com/gbordier/2009/05/05/powershell-and-writing-files-how-fast-can-you-write-to-a-file/
