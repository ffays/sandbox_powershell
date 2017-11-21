# usage: powershell -file ftps-batch.ps1 -login demo -password password -uri ftps://test.rebex.net/readme.txt

param (
   [Parameter(Mandatory=$true)][string]$uri,
   [string]$login,
   [string]$password,
   [int]$timeout = 30,
   [string]$folder = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\').'{374DE290-123F-4565-9164-39C4925E467B}',
   [string]$filename = "",
   [switch]$ignoreCertificateErrors,
   [switch]$newest
)

$ErrorActionPreference = "Stop"
$ssl = $uri.StartsWith("ftps", "CurrentCultureIgnoreCase")
$uri = $uri -ireplace "ftps://", "ftp://"

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


$request = [System.Net.FtpWebRequest]::Create($uri)

if(-not (([string]::IsNullOrEmpty($login)) -or ([string]::IsNullOrEmpty($password)))) {
    $request.Credentials = New-Object System.Net.NetworkCredential($login, $password)
}
$request.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
$request.EnableSsl = $ssl
$request.UseBinary = $True
$request.UsePassive = $True
$request.KeepAlive = $False
$request.Timeout = $timeout * 1000

$response = $request.GetResponse()
if($response.StatusCode -eq [System.Net.FtpStatusCode]::DataAlreadyOpen -or $response.StatusCode -eq [System.Net.FtpStatusCode]::OpeningData) {
    $url = $uri.Substring(0, $uri.Length - $response.ResponseUri.LocalPath.Length + 1)
    $responseStream = $response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($responseStream)
    $responseText = $reader.ReadToEnd()
    $fileList = $responseText.Split([Environment]::NewLine) | ?  {-not [string]::IsNullOrEmpty($_)}
}
$response.Close()
Remove-Variable uri, response, request, responseStream, reader, responseText

if($newest -and ($fileList.Length -gt 1)) {
    $map = @{}
    $fileList | % {
        $uri = $url + $_
        $request = [System.Net.FtpWebRequest]::Create($uri)

        if(-not (([string]::IsNullOrEmpty($login)) -or ([string]::IsNullOrEmpty($password)))) {
            $request.Credentials = New-Object System.Net.NetworkCredential($login, $password)
        }
        $request.Method = [System.Net.WebRequestMethods+Ftp]::GetDateTimestamp
        $request.EnableSsl = $ssl
        $request.UseBinary = $True
        $request.UsePassive = $True
        $request.KeepAlive = $False
        $request.Timeout = $timeout * 1000

        $response = $request.GetResponse()
        $map[$_] = $response.LastModified
        $response.Close()
        Remove-Variable uri, response, request    
    }
    $fileList = @($($map.GetEnumerator() | Sort-Object -Descending -Property value | Select-Object -First 1 Name)[0].name)
    Remove-Variable map
}

$fileList | % {

    $uri = $url + $_
    $request = [System.Net.FtpWebRequest]::Create($uri)

    if(-not (([string]::IsNullOrEmpty($login)) -or ([string]::IsNullOrEmpty($password)))) {
        $request.Credentials = New-Object System.Net.NetworkCredential($login, $password)
    }
    $request.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
    $request.EnableSsl = $ssl
    $request.UseBinary = $True
    $request.UsePassive = $True
    $request.KeepAlive = $False
    $request.Timeout = $timeout * 1000

    $response = $request.GetResponse()
    if($response.StatusCode -eq [System.Net.FtpStatusCode]::DataAlreadyOpen -or $response.StatusCode -eq [System.Net.FtpStatusCode]::OpeningData) {
        $responseStream = $response.GetResponseStream()
        $reader = New-Object System.IO.BinaryReader($responseStream)

        if($newest -and -not ([string]::IsNullOrEmpty($filename))) {
            # Keep given name
        } else {
            $localPath = $response.ResponseUri.LocalPath
            $filename = [System.IO.Path]::GetFileName($localPath)
            Remove-Variable localPath
        }
        $filename = Join-Path $folder -ChildPath $filename

        $writer = [IO.File]::OpenWrite($filename)
        $buffer = New-Object byte[] 1024
        $bytesRead = $reader.Read($buffer,0,$buffer.Length)
        while($bytesRead -ne 0) {
            $writer.Write($buffer, 0, $bytesRead);
            $bytesRead = $reader.Read($buffer,0,$buffer.Length)
        }

        $writer.Flush()
        $writer.Close()
        Write-Host $filename
    }
    $response.Close()
    Remove-Variable uri, response, request, responseStream, reader, filename, writer, buffer, bytesRead
}

# https://stackoverflow.com/questions/1279041/powershell-ftpwebrequest-and-enablessl-true
# http://test.rebex.net/
# https://docs.microsoft.com/en-us/dotnet/framework/network-programming/how-to-download-files-with-ftp
# https://docs.microsoft.com/en-us/dotnet/framework/network-programming/how-to-upload-files-with-ftp
# https://blogs.technet.microsoft.com/gbordier/2009/05/05/powershell-and-writing-files-how-fast-can-you-write-to-a-file/
# https://social.technet.microsoft.com/Forums/windowsserver/en-US/79958c6e-4763-4bd7-8b23-2c8dc5457131/sample-code-required-for-invokerestmethod-using-https-and-basic-authorisation?forum=winserverpowershell
