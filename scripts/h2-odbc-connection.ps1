$ErrorActionPreference = "Stop"

$conn = New-Object System.Data.Odbc.OdbcConnection
$conn.ConnectionString = "Driver={PostgreSQL Unicode(x64)};Server=localhost;Port=5435;Database=~/test;Username=sa;Password=sa;"
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT 1 AS id UNION SELECT 2 UNION SELECT 3;"
$reader = $cmd.ExecuteReader()
$datatable = New-Object System.Data.DataTable
try {
    $datatable.Load($reader)
} catch {
    $ex =  $_
}
$datatable | Format-Table -Auto 
$conn.Close()
