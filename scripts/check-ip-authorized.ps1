Remove-Variable * -ErrorAction SilentlyContinue

$fullyQualifiedDomainName = 'amazon.com'

$ErrorActionPreference = 'Stop'
$ipAddresses = [System.Net.Dns]::GetHostAddresses($fullyQualifiedDomainName).IPAddressToString

function isAddressAuthorized([String] $ipAddress, [String] $ipRange) {
    $ip = [system.net.ipaddress]::Parse($ipAddress).GetAddressBytes()
    [array]::Reverse($ip)
    $ip = [system.BitConverter]::ToUInt32($ip, 0)

    ($ipSubnet, $ipSubnetBitlength) = $ipRange -split '/'

    $subnet = [system.net.ipaddress]::Parse($ipSubnet).GetAddressBytes()
    [array]::Reverse($subnet)
    $subnet = [system.BitConverter]::ToUInt32($subnet, 0)

    $bits = [convert]::ToUInt32($ipSubnetBitlength, 10)
    $mask = [convert]::ToUInt32('FFFFFFFF', 16) -bxor ((1 -shl (32 - $bits)) - 1)

    $authorized = ($subnet -band $mask) -eq ($ip -band $mask)

    return $authorized
}

$ipRanges = $($(Invoke-WebRequest -Uri https://ip-ranges.amazonaws.com/ip-ranges.json).content | ConvertFrom-Json).prefixes `
| Where-Object {$_.region -imatch '^.*'} `
| Select-Object ip_prefix `
| Sort-Object {"{0:d3}.{1:d3}.{2:d3}.{3:d3}/{4:d2}" -f @(@($_.ip_prefix.split('[./]')) | %{[convert]::ToInt32($_)})} -Unique `
| %{$_.ip_prefix.Trim()}


$authorizations = $($ipRanges | % { $ipRange = $_; $ipAddresses | % { isAddressAuthorized $_  $ipRange } } | ? { $_ })
$authorizations -ne $null -and $authorizations.Length -eq $ipAddresses.Length
