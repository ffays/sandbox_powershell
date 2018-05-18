# Remove-Variable * -ErrorAction SilentlyContinue

$ErrorActionPreference = "Stop"

$downloadsFolder = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\').'{374DE290-123F-4565-9164-39C4925E467B}'
$fileName = Join-Path $downloadsFolder -ChildPath "excel-write-data2.xlsx"

# Extract data via SQL
function OleDbQuery([System.Data.OleDb.OleDbConnection]$oleDbConn, [String]$sql) {
    $oleDbAdapter = New-Object 'System.Data.OleDb.OleDbDataAdapter' -ArgumentList $sql, $oleDbConn
    $dataTable = New-Object 'System.Data.DataTable'
    $oleDbAdapter.Fill($dataTable) | Out-Null
    return $dataTable
}

$oleDbConn = New-Object 'System.Data.OleDb.OleDbConnection' -ArgumentList "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=`"$fileName`";Extended Properties=`"Excel 12.0 Xml;HDR=YES`";"
$oleDbConn.Open()

OleDbQuery $oleDbConn "INSERT INTO [MY_DATA`$] ([Resource Name],[Quantity]) VALUES ('Sugar', 20)" | Out-Null
#OleDbQuery $oleDbConn "INSERT INTO [MY_DATA] ([Resource Name],[Quantity]) VALUES ('Orange', 10)" | Out-Null
#OleDbQuery $oleDbConn "INSERT INTO [MY_DATA] ([Resource Name],[Quantity]) VALUES ('Banana', 15)" | Out-Null
#OleDbQuery $oleDbConn "INSERT INTO [MY_DATA] ([Resource Name],[Quantity]) VALUES ('Apple', 25)" | Out-Null
#OleDbQuery $oleDbConn "INSERT INTO [MY_DATA] ([Resource Name],[Quantity]) VALUES ('Mango', 50)" | Out-Null
#OleDbQuery $oleDbConn "INSERT INTO [MY_DATA] ([Resource Name],[Quantity]) VALUES ('Apricot', 30)" | Out-Null
$oleDbConn.Close()

# Start Excel
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $true

# Open the Excel file
$workbook = $Excel.Workbooks.Open($fileName)
