# For each file that does not contain text is $sourceFolder, create a symbolic link from $sourceFolder into $redoFodler

# Note: itextsharp.dll must be located in the user's "Dowloads" folder

# Set-ExecutionPolicy RemoteSigned CurrentUser

# Articles
# https://github.com/itext/itextsharp
# https://social.technet.microsoft.com/Forums/scriptcenter/en-US/1268809d-5dc6-4cd2-a97f-a26bc3ae3a8b/using-powershell-to-parse-a-pdf-file?forum=ITCG


$sourceFolder = 'C:\TEMP\pdf-orig'
$targetFolder = 'C:\TEMP\pdf-ocr'
$redoFolder   = 'C:\TEMP\pdf-redo'

# User's "Dowloads" folder
$downloadsFolder = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\').'{374DE290-123F-4565-9164-39C4925E467B}'
$iTextSharpLibrary = Join-Path $downloadsFolder -ChildPath 'itextsharp.dll'

Unblock-File -Path $iTextSharpLibrary
Add-Type -Path $iTextSharpLibrary

Get-ChildItem -File -Recurse $targetFolder | Where-Object Extension -EQ '.pdf' | % {
  $targetFilename = $_.FullName
  # read the PDF with iTextSharp
  $reader = New-Object iTextSharp.text.pdf.pdfreader -ArgumentList $targetFilename
  $text = [iTextSharp.text.pdf.parser.PdfTextExtractor]::GetTextFromPage($reader, 1)
  $reader.Close()
  # Check if the PDF contains text, i.e. there is at least 20 words of more than 4 characters on the first page
  $words = $text -replace "[\W]+"," " -replace "\b\w{1,3}\b","" | Measure-Object -Word | Select-Object Words # remove words that are shorter than 4 letters
  $ok = $words.Words -ge 20 # check there is at least 20 words
  Write-Host "$($targetFilename)`t$ok"
  if(-Not $ok) {
    # Prepare redo folder structure
    $sourceFilename  = Join-Path $sourceFolder -ChildPath $targetFilename.Substring($targetFolder.Length+1)
    $redoFilename = Join-Path $redoFolder -ChildPath $targetFilename.Substring($targetFolder.Length+1)
    $redoFile = New-Object System.IO.FileInfo -ArgumentList $redoFilename
    if(-Not (Test-Path -Path $redoFile.Directory)){
        # Make sub-folder(s) in redo folder
        New-Item -ItemType directory -Path $redoFile.Directory | Out-Null
    }
    if(-Not (Test-Path -Path $redoFilename)){
        # Make symbolic link between source folder and redo folder
        New-Item -Path $redoFilename -ItemType SymbolicLink -Value $sourceFilename
    }
  }
}
