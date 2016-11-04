# Remove-Variable * -ErrorAction SilentlyContinue
# Add-Type -Assembly PresentationCore

$downloadsFolder = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\').'{374DE290-123F-4565-9164-39C4925E467B}'
$fileName = Join-Path $downloadsFolder -ChildPath "export.xlsx"

# Extract data via SQL
function OleDbQuery([System.Data.OleDb.OleDbConnection]$oleDbConn, [String]$sql) {
    $oleDbAdapter = New-Object 'System.Data.OleDb.OleDbDataAdapter' -ArgumentList $sql, $oleDbConn
    $dataTable = New-Object 'System.Data.DataTable'
    $oleDbAdapter.Fill($dataTable) | Out-Null
    return $dataTable
}

$oleDbConn = New-Object 'System.Data.OleDb.OleDbConnection' -ArgumentList "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=`"$fileName`";Extended Properties=`"Excel 12.0 Xml;HDR=YES`";"
$oleDbConn.Open()

$idSet = New-Object 'System.Collections.Generic.HashSet[string]' 
OleDbQuery $oleDbConn 'SELECT DISTINCT id FROM [data$]' | %{ $idSet.Add($_."id") } | Out-Null

$attributeSet = New-Object 'System.Collections.Generic.HashSet[string]'
OleDbQuery $oleDbConn 'SELECT DISTINCT attribute FROM [data$]' | %{ $attributeSet.Add($_."attribute") } | Out-Null

$oleDbConn.Close()
# Start Excel
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $true

# Open the Excel file
$workbook = $Excel.Workbooks.Open($fileName)

# Gather data from "data" sheet
$dataSheet = ($workbook.Worksheets | Where Name -eq "data")
$attributeCN, $idCN, $valueCN = $dataSheet.Range("A1:J1") | Where-Object Text -In @("attribute", "id", "value") | Sort-Object -Property Text  | %{ $_.Column }
$attributeC,  $idC,  $valueC = @($fieldCN, $idCN, $valueCN) | %{ [char](([int][char]’A’)+$_-1) }

#$rowCount    = [int]$excel.WorksheetFunction.CountIf($dataSheet.Range("A:A"), "<>")
#$columnCount = [int]$excel.WorksheetFunction.CountIf($dataSheet.Range("1:1"), "<>")
#$lastC       = [char](([int][char]’A’)+$columnCount-1)

#$dataRange = $dataSheet.Range("DATA")
#$idSet = New-Object 'System.Collections.Generic.HashSet[string]' 
#$attributeSet = New-Object 'System.Collections.Generic.HashSet[string]'
#1..$dataRange.Rows.Count | %{ $idSet.add($dataRange.Item($_,$idCN).Text); $attributeSet.add($dataRange.Item($_,$attributeCN).Text) } | Out-Null


# Add the "summary" sheet
function ExcelColumnNumberToColumnName([Int] $c) {
    $result = [char](([int][char]’A’)+($c-1)%26)
    $h = [int][math]::floor($c / [int] 26)
    if($h -gt 0) {
        $result = $result + [char](([int][char]’A’)+($h-1))
    }
    return $result
}

function CollectionToArray2D($collection)  {
    [ref]$result = [ref]$null
    $result.Value = New-Object 'string[,]' $collection.Count,1
    $i=0
    $collection | %{ $result.Value[$i,0] = $_; $i++}
    $result
}


$x = CollectionToArray2D($attributeSet)

$summarySheet = $workbook.Worksheets.Add()
$summarySheet.Name = "summary"
$summarySheet = ($workbook.Worksheets | Where Name -eq "summary")
$summarySheet.Cells.Item(1,1) = "id"
# $r = 2; $idSet | %{$summarySheet.Cells.Item($r, 1) = $_; $r++}
# [Windows.Clipboard]::SetText($idSet -join [Environment]::NewLine); $summarySheet.Paste($summarySheet.Range("A2"),$false)
$summarySheet.Range("A2:A"+($idSet.Count+1)).Value2 = (CollectionToArray2D $idSet).Value

$c = 2; $attributeSet | %{$summarySheet.Cells.Item(1, $c) = $_; $cc = ExcelColumnNumberToColumnName $c; $summarySheet.Range($cc + "2:" + $cc + ($idSet.Count + 1)).Formula = "=VLOOKUP(`$A2&`":`"&$cc`$1, DATA, $valueCN, FALSE)"; $c++} 
$summarySheet.Cells.Item(1,1).select() | Out-Null

# Display Eye-Candy
$excel.ActiveWindow.SplitRow = 1
$excel.ActiveWindow.FreezePanes = $true

$firstRow = $summarySheet.Range("1:1")
$firstRow.Activate() | Out-Null
$firstRow.Select() | Out-Null
$firstRow.AutoFilter(1,  [type]::Missing, [Microsoft.Office.Interop.Excel.XlAutoFilterOperator]::xlAnd, [type]::Missing, $true) | Out-Null

$summarySheet.Cells.EntireColumn.AutoFit()
$summarySheet.range("A1").Select()
