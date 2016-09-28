# Lists Amazon Web Services IP ranges located in Europe 
$($(Invoke-WebRequest -Uri https://ip-ranges.amazonaws.com/ip-ranges.json).content | ConvertFrom-Json).prefixes `
| where {$_.region -imatch '^eu-.*'} `
| select ip_prefix `
| Sort-Object {"{0:d3}.{1:d3}.{2:d3}.{3:d3}/{4:d2}" -f @(@($_.ip_prefix.split('[./]')) | %{[convert]::ToInt32($_)})} -Unique
