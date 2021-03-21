# Recover Windows 10 Product key from registry

$regKey = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
$productName = $regKey.ProductName
$digitalProductId = $regKey.DigitalProductId
$productId = [System.Text.Encoding]::ASCII.GetString($digitalProductId[0x08..0x1E])

$digits = @('B','C','D','F','G','H','J','K','M','P','Q','R','T','V','W','X','Y','2','3','4','6','7','8','9')
$offset = 52

$productKey = ""
$last = 0
$digitalProductId[66] = [byte]($digitalProductId[66] -band 0xf7)
for ($i = 24; $i -ge 0; $i--) {
    $current = 0
    for ($j = 14; $j -ge 0; $j--) {
        $current = $current -shl 8
        $current = $digitalProductId[$j + $offset] + $current
        $digitalProductId[$j + $offset] = [byte][Math]::Floor($current / 24)
        $current = $current % 24
        $last = $current
    }
    $productKey = $digits[$current] + $productKey
}

$productKey = $productKey.Substring(1, $last) + 'N' + $productKey.Substring($last + 1)

for ($i = 5; $i -lt $productKey.Length; $i += 6) {
    $productKey = $productKey.Substring(0, $i) + '-' + $productKey.Substring($i) 
}

$productInfo = @{ ProductName = $productName; ProductId = $productId; ProductKey = $productKey}

$productInfo