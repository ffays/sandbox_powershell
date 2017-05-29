Add-Type -Path c:\temp\itextsharp.dll

# https://github.com/itext/itextsharp
# https://social.technet.microsoft.com/Forums/scriptcenter/en-US/1268809d-5dc6-4cd2-a97f-a26bc3ae3a8b/using-powershell-to-parse-a-pdf-file?forum=ITCG

Get-ChildItem -File -Recurse | Where-Object Extension -EQ '.pdf' | % {
  $reader = New-Object iTextSharp.text.pdf.pdfreader -ArgumentList $_.FullName
  $text = [iTextSharp.text.pdf.parser.PdfTextExtractor]::GetTextFromPage($reader, 1)
  $words = $text -replace "[\W]+"," " -replace "\b\w{1,3}\b","" | Measure-Object -Word | Select-Object Words
  Write-Host "$($_.FullName)`t$($words.Words -ge 20)"
  $reader.Close()
}
