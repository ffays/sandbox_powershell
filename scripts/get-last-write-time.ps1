Get-ChildItem -Recurse | Select-Object LastWriteTime | Sort-Object -Descending LastWriteTime | Select-Object -First 1
