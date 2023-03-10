Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Search-Zip {
    [cmdletbinding()]
    param (
        [parameter(mandatory=$true)]$Path,
        [parameter(mandatory=$true)]$Regex,
        [switch]$Recurse,
        $namespace = $null
    )

    process {
        Get-ChildItem -Path:$Path -Recurse:$Recurse | % {
            $zip = $_
            ([System.IO.Compression.ZipArchive]([System.IO.Compression.ZipFile]::OpenRead($zip))).Entries | ? {
                $entry = $_
                $entry.Name -match $Regex
            } |  % {
               $zip.Name + ":" + $_.FullName
            }
        }
    }
}
