# Usage: Get-Content -Encoding Byte 'out.txt' | Get-HexDump -Encoding unicode
# Article: http://superuser.com/questions/468456/how-can-i-view-the-binary-contents-of-a-file-natively-in-windows-7-is-it-possi
function Get-HexDump {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [byte[]] $Bytes,
        [Parameter(ValueFromPipeline = $false)]
        [string] $Encoding
    )

    BEGIN {
        if ([string]::IsNullOrEmpty($Encoding) -eq $true) {
            $Encoding = "ascii"
        }

        if ($Encoding -inotin [System.Text.Encoding]::GetEncodings().Name + "ascii" + "unicode") {
            Throw New-Object ArgumentException("Encoding must be $([System.Text.Encoding]::GetEncodings().Name -join ", "), unicode, or ascii.", '$Encoding')
        }

        $displayEncoding = [System.Text.Encoding]::GetEncoding($Encoding)

        $counter = 0
        $hexRow = ""
        [byte[]] $buffer = @()
    }

    PROCESS {
        foreach ($byte in $Bytes) {
            $buffer += $byte
            $hexValue = $byte.ToString("X2")

            if ($counter % 16 -eq 0) {
                $buffer = @($byte)
                $hexRow = "$($counter.ToString("X8")): $($hexValue) "
            } elseif ($counter % 16 -eq 15) {
                $bufferChars = $displayEncoding.GetChars($buffer);
                $bufferText = (($bufferChars | %{ if ([char]::IsControl($_) -eq $true) { "." } else { "$_" } }) -join "")
                $hexRow += "$($hexValue)   $($bufferText)"
                $hexRow
            }
            else {
                $hexRow += "$($hexValue) "
            }

            $counter++
        }
    }

    END {
        $counter--

        if ($counter % 16 -ne 15) {
            $hexRow += " " * (((16 - $counter % 16) * 3) - 1)
            $bufferChars = $displayEncoding.GetChars($buffer);
            $bufferText = (($bufferChars | %{ if ([char]::IsControl($_) -eq $true) { "." } else { "$_" } }) -join "")
            $hexRow += "$($bufferText)"
            $hexRow
        }
    }
}
