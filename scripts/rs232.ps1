[System.IO.Ports.SerialPort]::GetPortNames()
#$port = New-Object System.IO.Ports.SerialPort COM7,9600,None,8,one
$port = New-Object System.IO.Ports.SerialPort COM7,115200,None,8,one
$port.Open()
#$port.Write("AAA AAA AAA`n" )
$port.WriteLine("AAA AAA AAA" )
$port.Close()