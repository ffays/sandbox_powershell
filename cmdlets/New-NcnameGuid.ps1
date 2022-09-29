function New-NcnameGuid {
	$b = (New-Guid).ToByteArray()
	New-Object Guid(,(@($b[0],$b[1],$b[2],[Byte]($b[3] -bor 160),$b[4],$b[5],$b[6],$b[7],$b[8],$b[9],$b[10],$b[11],$b[12],$b[13],$b[14],$b[15]) -as [Byte[]]))
}
