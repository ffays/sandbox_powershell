# Article:  [Get vendor and product name from VID and PID in Android](https://felhr85.net/2014/06/27/get-vendor-and-product-name-from-vid-and-pid-in-android/)
# Resource: [Win32_USBControllerDevice class](https://msdn.microsoft.com/en-us/library/aa394505(v=vs.85).aspx)
# Resource: [The USB ID Repository](http://www.linux-usb.org/usb-ids.html)

# lsusb
Get-WmiObject Win32_PnPEntity |`
  %{$_.HardwareID} |`
  Where-Object { $_ -match "(USB|HID)\\VID_[0-9A-F]{4}&PID_[0-9A-F]{4}" } |`
  %{'{0}:{1}' -f $_.Substring(8,4).toLower(),$_.Substring(17,4).toLower() } |`
  Sort-Object -Unique

Get-WmiObject Win32_USBControllerDevice |`
  %{[wmi]($_.Dependent)} |`
  Sort-Object Manufacturer,Description,DeviceID |`
  Format-Table -GroupBy Name Description,Service,DeviceID

Get-WmiObject Win32_PnPEntity -Filter "Name like '%High Definition Audio Controller%'"
Get-WmiObject -Query "SELECT * FROM Win32_PNPEntity WHERE Name like '%High Definition Audio Controller%'"
