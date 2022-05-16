$ErrorActionPreference = "Stop"
Remove-Variable * -ErrorAction SilentlyContinue

$list1 = [System.Collections.ArrayList]@()
$list2 = [System.Collections.ArrayList]@()
foreach ($a in [AppDomain]::CurrentDomain.GetAssemblies()) {
    if (-not $a.IsDynamic) {
	    $parts = $a.Location.Split('\\')
	    $dllFileName = $parts[$parts.Length - 1]
        $co1 = New-Object PSCustomObject
        $co1 | Add-Member -type NoteProperty -name DLL -Value $dllFileName
        $co1 | Add-Member -type NoteProperty -name Location -Value $a.Location
	    foreach ($t in $a.GetTypes()) {
		    if ($t.IsPublic) {
                $co2 = New-Object PSCustomObject
                $co2 | Add-Member -type NoteProperty -name DLL -Value $dllFileName
			    if ($t.Namespace -ne $null) {
                    $co2 | Add-Member -type NoteProperty -name Namespace -Value $t.Namespace
			    }
                $co2 | Add-Member -type NoteProperty -name Name -Value $t.Name
                $list2.Add($co2) | Out-Null
		    }
	    }
        $list1.Add($co1) | Out-Null
    }
}

$list1 | Format-Table -Property * -AutoSize | Out-String -Width 4096
$list2 | Format-Table -Property * -AutoSize | Out-String -Width 4096
