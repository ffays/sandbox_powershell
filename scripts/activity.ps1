# Simulate a double "Scroll lock" key stroke every minutes
$ws = New-Object -ComObject wscript.shell; for($i=1; $i -le 1440; $i++) { $ws.SendKeys("{SCROLLLOCK}"); Start-Sleep -m $(if(($i -bAND 1) -eq 0) {100} else {59900}) }
