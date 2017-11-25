# usage: sum -file readme.txt -hash SHA256

 # hash algorithms : MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512

 param (
   [Parameter(Mandatory=$true)][string]$file,
   [string]$hash = 'SHA1'
 )

 $(certutil.exe -hashfile "$file" $hash.ToUpper())[1] -replace ' ',''
