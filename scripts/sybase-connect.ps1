Remove-Variable * -ErrorAction SilentlyContinue
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName ("Sap.Data.SQLAnywhere.v4.5, Version=17.0.8.40434, Culture=neutral, PublicKeyToken=f222fc4333e0d400")

# Connection string
$connectionString = "DSN=My Data Source Name;DBN=My Database Name;UID=My User ID;PWD=My User Password"

# Create SAConnection object
$conn = New-Object Sap.Data.SQLAnywhere.SAConnection($connectionString)

# Connect to remote IQ server
$conn.Open()

# simple query
$query = @'
SELECT 1
'@

# Create a SACommand object and feed it the simple $query
$command = New-Object Sap.Data.SQLAnywhere.SACommand($query, $conn)

# Execute the query on the remote IQ server
$reader = $command.ExecuteReader()

# create a DataTable object
$datatable = New-Object System.Data.DataTable

# Load the results into the $datatable object
try {
    $datatable.Load($reader)
} catch {
    $ex =  $_
}

# Send the results to the screen in a formatted table
$datatable | Format-Table -Auto
