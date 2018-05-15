$ErrorActionPreference = "Stop"

$builder = [System.Text.StringBuilder]::new()
$builder2 = [System.Text.StringBuilder]::new()

foreach ($a in [AppDomain]::CurrentDomain.GetAssemblies()) {
	if (-not $a.IsDynamic) {
		$parts = $a.Location.Split('\\')
		$dllFileName = $parts[$parts.Length - 1]
		$builder2.Append($dllFileName) | Out-Null
		$builder2.Append(",") | Out-Null
		$builder2.Append($a.Location) | Out-Null
		$builder2.AppendLine() | Out-Null
		foreach ($t in $a.GetTypes()) {
			 if ($t.IsPublic) {
				$builder.Append($dllFileName) | Out-Null
				$builder.Append(",") | Out-Null
				if ($t.Namespace -ne $null) {
					$builder.Append($t.Namespace) | Out-Null
					$builder.Append(".") | Out-Null
				}
				$builder.Append($t.Name) | Out-Null
				$builder.AppendLine() | Out-Null
			}
		}
	}
}
$builder.Append($builder2.ToString()) | Out-Null
Write-Host $builder.ToString()
