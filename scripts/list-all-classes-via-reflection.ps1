$ErrorActionPreference = "Stop"

$list1 = @()
$list2 = @()
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
                $list2 += $co2
		    }
	    }
        $list1 += $co1
    }
}

$list1
$list2

